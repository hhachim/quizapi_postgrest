FROM postgres:15

# Installation des dépendances nécessaires
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       make \
       gcc \
       postgresql-server-dev-15 \
    && rm -rf /var/lib/apt/lists/*

# Cloner le dépôt pgjwt
RUN cd /tmp \
    && git clone https://github.com/michelp/pgjwt.git \
    && cd pgjwt \
    && make \
    && make install

# Nettoyage
RUN apt-get purge -y git make gcc postgresql-server-dev-15 \
    && apt-get autoremove -y \
    && rm -rf /tmp/pgjwt