class CitadelOrchestra < Formula
  desc "Sandboxed environments and multi-agent dev team orchestrator for Claude Code"
  homepage "https://github.com/andriast/citadel-orchestra"
  url "https://github.com/andriast/citadel-orchestra/archive/refs/heads/main.tar.gz"
  version "0.1.0"
  license "MIT"

  depends_on "node"

  def install
    # Install all files to libexec (private, not in PATH)
    libexec.install Dir["*"]

    # Make scripts executable
    chmod 0755, libexec/"co-sandbox.sh"
    chmod 0755, libexec/"co-team.sh"

    # Create wrapper scripts in bin (added to PATH by Homebrew)
    # co-safe
    (bin/"co-safe").write <<~SH
      #!/bin/bash
      exec "#{libexec}/co-sandbox.sh" --dangerously-skip-permissions "$@"
    SH

    # co-rebuild
    (bin/"co-rebuild").write <<~SH
      #!/bin/bash
      exec "#{libexec}/co-sandbox.sh" --rebuild --dangerously-skip-permissions "$@"
    SH

    # co-team
    (bin/"co-team").write <<~SH
      #!/bin/bash
      exec "#{libexec}/co-team.sh" "$@"
    SH

    # co-team-simple
    (bin/"co-team-simple").write <<~SH
      #!/bin/bash
      exec "#{libexec}/co-team.sh" --dashboard simple "$@"
    SH

    # co-team-rebuild
    (bin/"co-team-rebuild").write <<~SH
      #!/bin/bash
      exec "#{libexec}/co-team.sh" --rebuild "$@"
    SH

    # co-team-sdk
    (bin/"co-team-sdk").write <<~SH
      #!/bin/bash
      exec "#{libexec}/co-team.sh" --mode sdk "$@"
    SH

    # co-team-sdk-simple
    (bin/"co-team-sdk-simple").write <<~SH
      #!/bin/bash
      exec "#{libexec}/co-team.sh" --mode sdk --dashboard simple "$@"
    SH

    # co-team-sdk-rebuild
    (bin/"co-team-sdk-rebuild").write <<~SH
      #!/bin/bash
      exec "#{libexec}/co-team.sh" --mode sdk --rebuild "$@"
    SH

    # co-stop
    (bin/"co-stop").write <<~SH
      #!/bin/bash
      docker stop $(docker ps -q) 2>/dev/null
      echo "All containers stopped"
    SH
  end

  def caveats
    <<~EOS
      Citadel Orchestra requires Docker Desktop to be installed and running.

        brew install --cask docker

      You also need Claude Code CLI:

        npm install -g @anthropic-ai/claude-code
        claude login

      For Docker containers, generate a long-lived token:

        claude setup-token

      Commands available:
        co-safe                  Sandboxed Claude in current directory
        co-team <project>        Dev team with TUI dashboard
        co-team-simple <project> Dev team, plain CLI
        co-team-sdk <project>    Dev team, SDK mode (API key)
        co-stop                  Stop all running containers

      For full documentation:
        https://github.com/andriast/citadel-orchestra
    EOS
  end

  test do
    assert_match "co-sandbox", (libexec/"co-sandbox.sh").read
    assert_match "co-team", (libexec/"co-team.sh").read
  end
end
