# Contributing to xkeen-web-ui

Thank you for your interest in contributing! This document provides guidelines for contributing to xkeen-web-ui.

## Development Setup

### Prerequisites

- Node.js >= 14.0.0
- Git
- Text editor or IDE
- (Optional) Keenetic router or VM for testing

### Local Development

1. Fork and clone the repository:

```bash
git clone https://github.com/yourusername/xkeen-web-ui.git
cd xkeen-web-ui
```

2. Create a development environment:

```bash
# No dependencies to install - pure Node.js!
# Just run the server
node server.js
```

3. Access at http://localhost:91

### Project Structure

```
xkeen-web-ui/
├── server.js              # Backend server (pure Node.js)
├── public/
│   └── index.html        # Frontend (HTML + CSS + JS inline)
├── files/
│   ├── S90xkeen-web-ui  # Init.d script
│   └── xkeen-web-ui.conf # Config template
├── build-opkg.sh         # Package build script
├── Makefile              # OpenWrt/Entware Makefile
└── README.md             # Documentation
```

## Making Changes

### Code Style

- **JavaScript**: Follow standard Node.js conventions
  - Use single quotes for strings
  - 2-space indentation
  - Semicolons required
  
- **HTML/CSS**: Standard formatting
  - 2-space indentation
  - Semantic HTML
  - CSS variables for theming

### Commit Messages

Use conventional commit format:

```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

Examples:
```
feat(ui): add file upload functionality
fix(auth): correct session timeout handling
docs(readme): update installation instructions
```

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `refactor/description` - Code refactoring

## Testing

### Manual Testing

1. Start the server:
```bash
node server.js
```

2. Test features:
   - [ ] Login with correct/incorrect credentials
   - [ ] Load config files
   - [ ] Edit and save files
   - [ ] Service control (start/stop/restart)
   - [ ] Theme toggle
   - [ ] Session timeout
   - [ ] Multiple tabs

3. Test on actual router (if available):
```bash
# Build package
./build-opkg.sh

# Copy to router
scp build/*.ipk root@192.168.1.1:/tmp/

# Install and test
ssh root@192.168.1.1
opkg install /tmp/xkeen-web-ui_*.ipk
/opt/etc/init.d/S90xkeen-web-ui start
```

### Package Testing

Test the opkg package:

```bash
# Build
chmod +x build-opkg.sh
./build-opkg.sh

# Inspect package contents
ar t build/xkeen-web-ui_*.ipk
tar tzf control.tar.gz
tar tzf data.tar.gz
```

## Pull Request Process

1. **Create an issue** first to discuss changes (for major changes)

2. **Fork** the repository

3. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature
   ```

4. **Make your changes**:
   - Write clear, documented code
   - Follow project conventions
   - Test thoroughly

5. **Commit** with clear messages:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

6. **Push** to your fork:
   ```bash
   git push origin feature/your-feature
   ```

7. **Open a Pull Request**:
   - Provide clear description
   - Reference related issues
   - Include screenshots for UI changes
   - Ensure CI passes

8. **Review process**:
   - Maintainers will review
   - Address feedback
   - Iterate if needed

## Areas for Contribution

### High Priority

- [ ] Add automated tests
- [ ] Implement file backup/restore
- [ ] Add multi-language support (i18n)
- [ ] Improve error handling
- [ ] Add log viewing/filtering

### Features

- [ ] Syntax highlighting for config files
- [ ] Config validation
- [ ] Diff view for changes
- [ ] Multiple user accounts
- [ ] API rate limiting
- [ ] WebSocket for live updates
- [ ] File upload/download

### Documentation

- [ ] Video tutorials
- [ ] Troubleshooting guide
- [ ] API documentation
- [ ] Screenshots and GIFs
- [ ] Translation to other languages

### Package Management

- [ ] Support for more architectures
- [ ] Integration with official repos
- [ ] Auto-update mechanism
- [ ] Package signing

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Assume good intentions

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Personal attacks
- Publishing private information

## Questions?

- Open an issue for bugs or feature requests
- Join discussions for general questions
- Contact maintainers for security issues

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in commits

Thank you for contributing! 🎉
