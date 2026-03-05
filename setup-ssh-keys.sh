#!/bin/bash

echo "Setting up SSH keys for GitHub and GitLab..."

# Generate GitHub key
if [ ! -f ~/.ssh/id_ed25519_github ]; then
    echo "Generating GitHub SSH key..."
    ssh-keygen -t ed25519 -C "cameronmonthe@example.com" -f ~/.ssh/id_ed25519_github -N ""
    echo "✅ GitHub key generated"
else
    echo "✅ GitHub key already exists"
fi

# Generate GitLab key
if [ ! -f ~/.ssh/id_ed25519_gitlab ]; then
    echo "Generating GitLab SSH key..."
    ssh-keygen -t ed25519 -C "cameronmonthe@example.com" -f ~/.ssh/id_ed25519_gitlab -N ""
    echo "✅ GitLab key generated"
else
    echo "✅ GitLab key already exists"
fi

# Backup existing config
if [ -f ~/.ssh/config ]; then
    cp ~/.ssh/config ~/.ssh/config.backup
    echo "✅ Backed up existing SSH config"
fi

# Create new SSH config
cat > ~/.ssh/config << 'EOF'
Include /Users/cameronmonthe/.colima/ssh_config

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
    IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config
echo "✅ SSH config updated"

# Add keys to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_github
ssh-add ~/.ssh/id_ed25519_gitlab
echo "✅ Keys added to ssh-agent"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 NEXT STEPS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Add GitHub public key to GitHub:"
echo "   https://github.com/settings/keys"
echo ""
cat ~/.ssh/id_ed25519_github.pub
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "2. Add GitLab public key to GitLab:"
echo "   https://gitlab.com/-/profile/keys"
echo ""
cat ~/.ssh/id_ed25519_gitlab.pub
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "3. Update GitHub remote to use SSH:"
echo "   git remote set-url github git@github.com:cmonthe2/terraform-module.git"
echo ""
echo "4. Test connections:"
echo "   ssh -T git@github.com"
echo "   ssh -T git@gitlab.com"
echo ""
echo "5. Push to both remotes:"
echo "   git push origin main    # GitLab"
echo "   git push github main    # GitHub"
echo ""
