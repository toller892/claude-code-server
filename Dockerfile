FROM node:22-slim

RUN apt-get update && apt-get install -y \
    git curl openssh-server sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code + OpenClaw
RUN npm install -g @anthropic-ai/claude-code openclaw

# Create user
RUN useradd -m -s /bin/bash claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH setup
RUN mkdir /var/run/sshd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Password + exec security + OpenClaw Node at runtime
ENV SSH_PASSWORD=changeme
ENV OPENCLAW_GATEWAY_TOKEN=""
ENV OPENCLAW_GATEWAY_HOST=""
RUN echo '#!/bin/bash\necho "claude:$SSH_PASSWORD" | chpasswd\nsu - claude -c "openclaw config set tools.exec.security full" 2>/dev/null\nif [ -n "$OPENCLAW_GATEWAY_HOST" ] && [ -n "$OPENCLAW_GATEWAY_TOKEN" ]; then\n  su - claude -c "OPENCLAW_GATEWAY_TOKEN=$OPENCLAW_GATEWAY_TOKEN openclaw node run --host $OPENCLAW_GATEWAY_HOST --port 443 --tls --display-name claude-code-server &"\nfi\nexec /usr/sbin/sshd -D' > /entrypoint.sh && chmod +x /entrypoint.sh

# Claude Code config directory
RUN mkdir -p /home/claude/.claude && chown -R claude:claude /home/claude

EXPOSE 22

# Start SSH
CMD ["/bin/bash", "/entrypoint.sh"]
