# Projeto Vagrant + Jenkins

Projeto da disciplina de DevOps: duas VMs criadas com **Vagrant**, uma servindo como host do **Jenkins** e outra simulando um ambiente de **produção** ("prod"), ambas com **Node.js** instalado.

Repositório base: [carlhenriquex/projeto-vagrant-jenkins](https://github.com/carlhenriquex/projeto-vagrant-jenkins)

---

## Arquitetura

| VM | Hostname | IP privado | Porta exposta no host | Instalado |
|---|---|---|---|---|
| `jenkins` | `jenkins-server` | `192.168.56.10` | `localhost:8081` → Jenkins (8080) | Jenkins + Node.js |
| `prod` | `prod-server` | `192.168.56.20` | `localhost:3000` → App (3000) | Node.js |

Ambas as VMs usam a box `ubuntu/jammy64`, 1024MB de RAM (1~2 CPUs) e são definidas no mesmo `Vagrantfile` através de dois blocos `config.vm.define`.

---

## Estrutura do repositório

```
.
├── Vagrantfile
├── README.md
├── app/                      # pasta sincronizada com /var/www/app na VM prod
└── scripts/
    ├── setup-jenkins.sh      # provisiona a VM jenkins (Jenkins + Node.js)
    └── setup-prod.sh         # provisiona a VM prod (Node.js)
```

---

## Como rodar

**Pré-requisitos:** VirtualBox e Vagrant instalados no host.

```bash
# clonar o repositório (ou o seu fork)
git clone https://github.com/carlhenriquex/projeto-vagrant-jenkins.git
cd projeto-vagrant-jenkins

# subir as duas VMs
vagrant up
```

Isso vai criar as duas VMs e rodar automaticamente os scripts de provisionamento. A primeira subida pode levar alguns minutos (download da box + instalação dos pacotes).

Se preferir subir uma VM por vez:
```bash
vagrant up jenkins
vagrant up prod
```

### Acessando o Jenkins

1. Abra `http://localhost:8081` no navegador do host.
2. Na tela "Unlock Jenkins", pegue a senha inicial dentro da VM:
   ```bash
   vagrant ssh jenkins -c "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
   ```
3. Escolha **"Install suggested plugins"**.
4. Crie o usuário administrador quando solicitado.

### Verificando o Node.js

```bash
vagrant ssh jenkins -c "node -v"
vagrant ssh prod -c "node -v"
```

### Acessando as VMs via SSH

```bash
vagrant ssh jenkins
vagrant ssh prod
```

---

## Extras implementados

### 1. `synced_folder` na VM prod

A pasta `./app` na raiz do projeto é sincronizada com `/var/www/app` dentro da VM `prod`, permitindo editar o código da aplicação no host e testá-lo direto na VM.

### 2. Conexão SSH entre `jenkins` e `prod`

Foi configurada autenticação por chave (sem senha) entre as duas VMs, permitindo que a `jenkins` acesse a `prod` via SSH — passo necessário para automatizar deploys em um pipeline real.

**Como foi feito** (executado manualmente como usuário `vagrant` dentro da VM `jenkins`):
```bash
# na VM jenkins
ssh-keygen -t ed25519 -C "jenkins-to-prod"
ssh-keyscan -H 192.168.56.20 >> ~/.ssh/known_hosts
cat ~/.ssh/id_ed25519.pub   # copiar a saída
```
```bash
# na VM prod, colar a chave pública copiada
echo "<chave-copiada>" >> ~/.ssh/authorized_keys
```
```bash
# de volta na jenkins, testar
ssh vagrant@192.168.56.20
```

Se a conexão abrir sem pedir senha, a configuração está correta.

> **Nota:** essa configuração foi feita manualmente para fins de teste/aprendizado. Em um cenário real, o ideal é automatizar esses passos em um script de provisionamento (ex.: `scripts/setup-ssh.sh`) para que rodem automaticamente no `vagrant up`.

---

## Problemas encontrados e resolvidos durante o desenvolvimento

Um histórico detalhado de todos os erros e diagnósticos está documentado em [`projeto-vagrant-jenkins-log.md`](./projeto-vagrant-jenkins-log.md). Resumo dos principais:

1. **`NO_PUBKEY` / repositório Jenkins não assinado** — corrigido adicionando `[signed-by=...]` na linha do `sources.list.d/jenkins.list`.
2. **`VERR_ALREADY_EXISTS` ao renomear pasta da VM** — VM órfã de uma tentativa anterior interrompida; resolvido com `VBoxManage unregistervm --delete` e `vagrant global-status --prune`.
3. **`NO_PUBKEY 7198F4B714ABFC68` persistente** — causa raiz real: o Jenkins trocou a chave de assinatura dos repositórios (dezembro/2025); o script baixava a chave antiga (`jenkins.io-2023.key`) em vez da nova (`jenkins.io-2026.key`).
4. **`Job for jenkins.service failed`** — a partir do Jenkins 2.555.1, é exigido Java 21+; o script instalava `openjdk-17-jre`. Corrigido trocando para `openjdk-21-jre`.
5. **Timeout de boot na VM jenkins** — problema transitório de primeiro boot (cloud-init) após um `vagrant destroy`; resolvido repetindo o `vagrant up`.

---

## Requisitos atendidos

- [x] Box `ubuntu/jammy64`
- [x] Hostname definido para ambas as VMs
- [x] IPs distintos (`192.168.56.10` e `192.168.56.20`)
- [x] Memória 1024MB, 1~2 CPUs
- [x] Provisionamento via Shell
- [x] Jenkins + Node.js na VM `jenkins`
- [x] Node.js na VM `prod`
- [x] (Extra) `synced_folder` para testar o app na `prod`
- [x] (Extra) Conexão SSH entre `jenkins` e `prod`