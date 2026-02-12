FROM node:22-slim

RUN apt-get update && apt-get install -y \
    git curl openssh-server sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create user
RUN useradd -m -s /bin/bash claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH setup
RUN mkdir /var/run/sshd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Password set via environment variable at runtime
ENV SSH_PASSWORD=changeme
RUN echo "#!/bin/bash\necho \"claude:\$SSH_PASSWORD\" | chpasswd && exec /usr/sbin/sshd -D" > /entrypoint.sh && chmod +x /entrypoint.sh

# Claude Code config directory
RUN mkdir -p /home/claude/.claude && chown -R claude:claude /home/claude

EXPOSE 22

# Start SSH
CMD ["/bin/bash", "/entrypoint.sh"]
