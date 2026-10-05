# 1. Usa uma imagem oficial do Node
FROM node:20-alpine

# 2. Define o diretório de trabalho dentro do container
WORKDIR /app

# 3. Copia os arquivos de dependência
COPY package*.json ./

# 4. Instala as dependências (incluindo devDependencies para conseguir compilar o TS)
RUN npm install

# 5. Copia o resto do código fonte
COPY . .

# 6. Compila o TypeScript para JavaScript (se houver script de build, ajuste aqui)
# Ou se rodar direto com ts-node, certifique-se de expor a porta certa
EXPOSE 3000

# 7. Comando para iniciar a aplicação
CMD ["npm", "run", "dev"] 
# (Dica: em produção, o ideal é compilar para JS puro e usar "node dist/index.js")