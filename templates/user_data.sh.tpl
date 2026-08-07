#!/bin/bash
dnf install -y httpd -y
systemctl enable httpd
systemctl start httpd
cat <<HTML > /var/www/html/index.html
<html>
<body>
<h1>Atividade 1 - Terraform</h1>
<p>Data: ${data}</p>
<p>Aluno: ${aluno}</p>
<p>Turma: ${turma}</p>
<p>Ambiente: ${ambiente}</p>
</body>
</html>
HTML
