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

# Set password for claude user
RUN echo "claude:claude2026" | chpasswd

# Claude Code config directory
RUN mkdir -p /home/claude/.claude && chown -R claude:claude /home/claude

EXPOSE 22

# Start SSH
CMD ["/usr/sbin/sshd", "-D"]
