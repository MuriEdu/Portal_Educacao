import sys
import psycopg2
import psycopg2.errors
from datetime import datetime

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QLabel, QListWidget, QListWidgetItem, QMessageBox,
    QGroupBox, QTabWidget, QFormLayout, QComboBox, QSpinBox, QLineEdit,
    QTextEdit
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont

DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "portal_educacao"
DB_USER = "admin"
DB_PASS = "admin"

class EnrollmentApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Portal da Educação")
        self.setGeometry(100, 100, 900, 700)

        self.conn = self.criar_conexao()
        if not self.conn:
            sys.exit(1)

        self.initUI()
        
        self.refresh_enroll_tab_data()

    def initUI(self):
        self.tab_widget = QTabWidget()
        self.setCentralWidget(self.tab_widget)

        enroll_tab_widget = self.create_enroll_tab()
        register_class_tab_widget = self.create_register_class_tab()
        register_discipline_tab_widget = self.create_register_discipline_tab()
        register_institution_tab_widget = self.create_register_institution_tab()

        self.tab_widget.addTab(enroll_tab_widget, "Matricular Aluno")
        self.tab_widget.addTab(register_class_tab_widget, "Cadastrar Turma")
        self.tab_widget.addTab(register_discipline_tab_widget, "Cadastrar Disciplina")
        self.tab_widget.addTab(register_institution_tab_widget, "Cadastrar Instituição")
        
        self.tab_widget.currentChanged.connect(self.on_tab_change)

    def create_enroll_tab(self):
        enroll_widget = QWidget()
        main_layout = QVBoxLayout(enroll_widget)

        title_label = QLabel("Matricular Aluno em Turma")
        title_label.setFont(QFont("Helvetica", 18, QFont.Weight.Bold))
        title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        main_layout.addWidget(title_label)
        
        lists_layout = QHBoxLayout()
        alunos_groupbox = QGroupBox("1. Selecione um Aluno")
        alunos_layout = QVBoxLayout()
        self.alunos_list = QListWidget()
        alunos_layout.addWidget(self.alunos_list)
        alunos_groupbox.setLayout(alunos_layout)
        lists_layout.addWidget(alunos_groupbox)
        
        turmas_groupbox = QGroupBox("2. Selecione uma Turma (apenas ativas com vagas)")
        turmas_layout = QVBoxLayout()
        self.turmas_list = QListWidget()
        turmas_layout.addWidget(self.turmas_list)
        turmas_groupbox.setLayout(turmas_layout)
        lists_layout.addWidget(turmas_groupbox)
        main_layout.addLayout(lists_layout)
        
        buttons_layout = QHBoxLayout()
        enroll_button = QPushButton("✅ Matricular Aluno Selecionado")
        enroll_button.clicked.connect(self.matricular_aluno)
        refresh_button = QPushButton("🔄 Atualizar Listas")
        refresh_button.clicked.connect(self.refresh_enroll_tab_data)
        buttons_layout.addWidget(enroll_button)
        buttons_layout.addWidget(refresh_button)
        main_layout.addLayout(buttons_layout)
        
        return enroll_widget

    def create_register_class_tab(self):
        register_widget = QWidget()
        layout = QFormLayout(register_widget)
        layout.setRowWrapPolicy(QFormLayout.RowWrapPolicy.WrapAllRows)

        self.professors_combo = QComboBox()
        self.disciplines_combo = QComboBox()
        self.status_combo = QComboBox()
        self.vagas_spinbox = QSpinBox()
        self.local_edit = QLineEdit()
        self.horario_edit = QLineEdit()
        self.ano_spinbox = QSpinBox()
        self.semestre_combo = QComboBox()
        
        self.status_combo.addItems(['ativa', 'planejada', 'encerrada'])
        self.semestre_combo.addItems(['1º Semestre', '2º Semestre'])
        self.vagas_spinbox.setRange(1, 200)
        self.vagas_spinbox.setValue(40)
        current_year = datetime.now().year
        self.ano_spinbox.setRange(current_year, current_year + 5)
        self.ano_spinbox.setValue(current_year)
        self.horario_edit.setPlaceholderText("Ex: Seg/Qua 10:00-12:00")
        self.local_edit.setPlaceholderText("Ex: Sala 301B ou Online")

        layout.addRow(QLabel("<b>Dados da Nova Turma</b>"))
        layout.addRow("Professor:", self.professors_combo)
        layout.addRow("Disciplina:", self.disciplines_combo)
        layout.addRow("Status da Turma:", self.status_combo)
        layout.addRow("Total de Vagas:", self.vagas_spinbox)
        layout.addRow("Local:", self.local_edit)
        layout.addRow("Horário:", self.horario_edit)
        layout.addRow("Ano:", self.ano_spinbox)
        layout.addRow("Semestre:", self.semestre_combo)
        
        register_button = QPushButton("🚀 Cadastrar Turma")
        register_button.clicked.connect(self.register_new_class)
        layout.addRow(register_button)
        
        return register_widget
        
    def create_register_discipline_tab(self):
        register_widget = QWidget()
        layout = QFormLayout(register_widget)
        
        self.institutions_combo = QComboBox()
        self.discipline_name_edit = QLineEdit()
        self.discipline_hours_spinbox = QSpinBox()
        self.discipline_ementa_edit = QTextEdit()
        self.discipline_objetivos_edit = QTextEdit()
        self.discipline_bibliografia_edit = QTextEdit()
        
        self.discipline_hours_spinbox.setRange(10, 400)
        self.discipline_hours_spinbox.setValue(60)
        self.discipline_ementa_edit.setFixedHeight(70)
        self.discipline_objetivos_edit.setFixedHeight(70)
        self.discipline_bibliografia_edit.setFixedHeight(70)
        self.discipline_name_edit.setPlaceholderText("Ex: Engenharia de Software I")

        layout.addRow("Instituição:", self.institutions_combo)
        layout.addRow("Nome da Disciplina:", self.discipline_name_edit)
        layout.addRow("Carga Horária (horas):", self.discipline_hours_spinbox)
        layout.addRow("Ementa:", self.discipline_ementa_edit)
        layout.addRow("Objetivos:", self.discipline_objetivos_edit)
        layout.addRow("Bibliografia:", self.discipline_bibliografia_edit)

        register_button = QPushButton("📚 Cadastrar Disciplina")
        register_button.clicked.connect(self.register_new_discipline)
        layout.addRow(register_button)

        return register_widget

    def create_register_institution_tab(self):
        register_widget = QWidget()
        layout = QFormLayout(register_widget)

        self.institution_name_edit = QLineEdit()
        self.institution_cnpj_edit = QLineEdit()
        self.institution_type_combo = QComboBox()
        self.institution_status_combo = QComboBox()
        self.institution_email_edit = QLineEdit()
        self.institution_phone_edit = QLineEdit()

        self.institution_type_combo.addItems(["Pública", "Privada"])
        self.institution_status_combo.addItems(["Ativa", "Inativa"])
        self.institution_cnpj_edit.setInputMask("99.999.999/9999-99")
        self.institution_phone_edit.setPlaceholderText("(99) 99999-9999")

        layout.addRow("Nome da Instituição:", self.institution_name_edit)
        layout.addRow("CNPJ:", self.institution_cnpj_edit)
        layout.addRow("Tipo:", self.institution_type_combo)
        layout.addRow("Status:", self.institution_status_combo)
        layout.addRow("E-mail de Contato:", self.institution_email_edit)
        layout.addRow("Telefone:", self.institution_phone_edit)

        register_button = QPushButton("🏢 Cadastrar Instituição")
        register_button.clicked.connect(self.register_new_institution)
        layout.addRow(register_button)

        return register_widget

    def criar_conexao(self):
        try:
            conn = psycopg2.connect(host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=DB_PASS, connect_timeout=5)
            return conn
        except psycopg2.OperationalError as e:
            QMessageBox.critical(None, "Erro de Conexão ❌", f"Não foi possível conectar ao banco de dados.\n\nO aplicativo será fechado.\n\nDetalhe: {e}")
            return None
    
    def populate_professors_combobox(self):
        self.professors_combo.clear()
        try:
            with self.conn.cursor() as cur:
                cur.execute("SELECT u.id, u.nome FROM Usuario u JOIN Professor p ON u.id = p.id_usuario ORDER BY u.nome;")
                for prof_id, prof_name in cur.fetchall():
                    self.professors_combo.addItem(prof_name, prof_id)
        except psycopg2.Error as e:
            QMessageBox.warning(self, "Erro", f"Erro ao buscar professores: {e}")

    def populate_disciplines_combobox(self):
        self.disciplines_combo.clear()
        try:
            with self.conn.cursor() as cur:
                cur.execute("SELECT id, nome FROM Disciplina ORDER BY nome;")
                for disc_id, disc_name in cur.fetchall():
                    self.disciplines_combo.addItem(disc_name, disc_id)
        except psycopg2.Error as e:
            QMessageBox.warning(self, "Erro", f"Erro ao buscar disciplinas: {e}")

    def populate_institutions_combobox(self):
        self.institutions_combo.clear()
        try:
            with self.conn.cursor() as cur:
                cur.execute("SELECT id, nome FROM Instituicao ORDER BY nome;")
                for inst_id, inst_name in cur.fetchall():
                    self.institutions_combo.addItem(inst_name, inst_id)
        except psycopg2.Error as e:
            QMessageBox.warning(self, "Erro", f"Erro ao buscar instituições: {e}")

    def register_new_class(self):
        id_professor = self.professors_combo.currentData()
        id_disciplina = self.disciplines_combo.currentData()
        status = self.status_combo.currentText()
        vagas = self.vagas_spinbox.value()
        local = self.local_edit.text()
        horario = self.horario_edit.text()
        ano = self.ano_spinbox.value()
        semestre = self.semestre_combo.currentIndex() + 1

        if not all([id_professor, id_disciplina, local.strip(), horario.strip()]):
            QMessageBox.warning(self, "Campos Vazios", "Todos os campos de texto e seleção são obrigatórios.")
            return

        try:
            with self.conn.cursor() as cur:
                sql = """
                    INSERT INTO Turma 
                    (id_professor, id_disciplina, status_turma, vagas_disp, vagas_totais, local, horario, ano, semestre)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
                """
                cur.execute(sql, (id_professor, id_disciplina, status, vagas, vagas, local, horario, ano, semestre))
            self.conn.commit()
            QMessageBox.information(self, "Sucesso", "Nova turma cadastrada com sucesso!")
            
            self.local_edit.clear()
            self.horario_edit.clear()

        except psycopg2.Error as e:
            self.conn.rollback()
            QMessageBox.critical(self, "Erro no Cadastro", f"Não foi possível cadastrar a turma:\n\n{e}")
            
    def register_new_discipline(self):
        id_instituicao = self.institutions_combo.currentData()
        nome = self.discipline_name_edit.text()
        carga_horaria = self.discipline_hours_spinbox.value()
        ementa = self.discipline_ementa_edit.toPlainText()
        objetivos = self.discipline_objetivos_edit.toPlainText()
        bibliografia = self.discipline_bibliografia_edit.toPlainText()

        if not all([id_instituicao, nome.strip()]):
            QMessageBox.warning(self, "Campos Obrigatórios", "A instituição e o nome da disciplina são obrigatórios.")
            return

        try:
            with self.conn.cursor() as cur:
                sql = """
                    INSERT INTO Disciplina
                    (id_instituicao, nome, carga_horaria, ementa, objetivos, bibliografia)
                    VALUES (%s, %s, %s, %s, %s, %s);
                """
                cur.execute(sql, (id_instituicao, nome, carga_horaria, ementa, objetivos, bibliografia))
            self.conn.commit()
            QMessageBox.information(self, "Sucesso", f"Disciplina '{nome}' cadastrada com sucesso!")

            self.discipline_name_edit.clear()
            self.discipline_ementa_edit.clear()
            self.discipline_objetivos_edit.clear()
            self.discipline_bibliografia_edit.clear()
            self.discipline_hours_spinbox.setValue(60)
            
            self.populate_disciplines_combobox()

        except psycopg2.Error as e:
            self.conn.rollback()
            QMessageBox.critical(self, "Erro no Cadastro", f"Não foi possível cadastrar a disciplina:\n\n{e}")

    def register_new_institution(self):
        nome = self.institution_name_edit.text()
        cnpj = self.institution_cnpj_edit.text()
        tipo = self.institution_type_combo.currentText()
        status = self.institution_status_combo.currentText()
        email = self.institution_email_edit.text()
        telefone = self.institution_phone_edit.text()

        if not all([nome.strip(), cnpj, email.strip()]):
            QMessageBox.warning(self, "Campos Obrigatórios", "Nome, CNPJ e E-mail são obrigatórios.")
            return

        try:
            with self.conn.cursor() as cur:
                sql = """
                    INSERT INTO Instituicao
                    (nome, cnpj, tipo_instituicao, status_instituicao, email, telefone)
                    VALUES (%s, %s, %s, %s, %s, %s);
                """
                cur.execute(sql, (nome, cnpj, tipo, status, email, telefone))
            self.conn.commit()
            QMessageBox.information(self, "Sucesso", f"Instituição '{nome}' cadastrada com sucesso!")

            self.institution_name_edit.clear()
            self.institution_cnpj_edit.clear()
            self.institution_email_edit.clear()
            self.institution_phone_edit.clear()
            
            self.populate_institutions_combobox()

        except psycopg2.Error as e:
            self.conn.rollback()
            QMessageBox.critical(self, "Erro no Cadastro", f"Não foi possível cadastrar a instituição:\n\n{e}")

    def on_tab_change(self, index):
        if index == 0:
            self.refresh_enroll_tab_data()
        elif index == 1:
            self.populate_professors_combobox()
            self.populate_disciplines_combobox()
        elif index == 2:
            self.populate_institutions_combobox()

    def refresh_enroll_tab_data(self):
        self.popular_lista_alunos()
        self.popular_lista_turmas()
        
    def popular_lista_alunos(self):
        self.alunos_list.clear()
        try:
            with self.conn.cursor() as cur:
                cur.execute("SELECT u.id, u.nome, a.matricula FROM Usuario u JOIN Aluno a ON u.id = a.id_usuario ORDER BY u.nome;")
                for aluno_id, nome, matricula in cur.fetchall():
                    display_text = f"{nome} (Matrícula: {matricula})"
                    item = QListWidgetItem(display_text)
                    item.setData(Qt.ItemDataRole.UserRole, aluno_id)
                    self.alunos_list.addItem(item)
        except psycopg2.Error as e:
            QMessageBox.warning(self, "Erro de Banco de Dados", f"Erro ao buscar alunos: {e}")

    def popular_lista_turmas(self):
        self.turmas_list.clear()
        try:
            with self.conn.cursor() as cur:
                cur.execute("SELECT t.id, d.nome, t.vagas_disp, t.vagas_totais FROM Turma t JOIN Disciplina d ON t.id_disciplina = d.id WHERE t.status_turma = 'ativa' AND t.vagas_disp > 0 ORDER BY d.nome;")
                for turma_id, nome, vagas_disp, vagas_totais in cur.fetchall():
                    display_text = f"{nome} (Vagas: {vagas_disp}/{vagas_totais})"
                    item = QListWidgetItem(display_text)
                    item.setData(Qt.ItemDataRole.UserRole, turma_id)
                    self.turmas_list.addItem(item)
        except psycopg2.Error as e:
            QMessageBox.warning(self, "Erro de Banco de Dados", f"Erro ao buscar turmas: {e}")

    def matricular_aluno(self):
        aluno_item = self.alunos_list.currentItem()
        turma_item = self.turmas_list.currentItem()
        if not aluno_item or not turma_item:
            QMessageBox.warning(self, "Seleção Inválida", "Por favor, selecione um aluno e uma turma.")
            return
        id_aluno = aluno_item.data(Qt.ItemDataRole.UserRole)
        id_turma = turma_item.data(Qt.ItemDataRole.UserRole)
        try:
            with self.conn.cursor() as cur:
                cur.execute("CALL sp_matricular_aluno(%s, %s);", (id_aluno, id_turma))
            self.conn.commit()
            aviso = self.conn.notices[-1].split(":")[-1].strip() if self.conn.notices else "Matrícula realizada com sucesso!"
            QMessageBox.information(self, "Sucesso ✅", aviso)
            self.refresh_enroll_tab_data()
            self.alunos_list.clearSelection()
            self.turmas_list.clearSelection()
        except psycopg2.Error as e:
            self.conn.rollback()
            error_message = str(e).split('\n')[0].split(':')[-1].strip()
            QMessageBox.critical(self, "Erro na Matrícula ❌", f"Não foi possível concluir a matrícula:\n\n➡️ {error_message}")

    def closeEvent(self, event):
        if self.conn: self.conn.close()
        event.accept()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = EnrollmentApp()
    window.show()
    sys.exit(app.exec())