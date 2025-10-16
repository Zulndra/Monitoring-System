#!/bin/bash

# 🚀 Deployment Helper Script
# Mempermudah workflow deployment untuk Monitoring System

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
}

# Check if gh CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) is not installed"
        print_info "Install from: https://cli.github.com/"
        print_info "Or use option 2b for web-based PR creation"
        return 1
    fi
    return 0
}

# Main menu
show_menu() {
    print_header "Monitoring System - Deployment Helper"
    echo "1) 🔨 Push to Staging (staged branch)"
    echo "2) 🚀 Promote to Production"
    echo "   a) Create PR via GitHub CLI"
    echo "   b) Get PR link (open in browser)"
    echo "3) 📊 Check Deployment Status"
    echo "4) 🔄 Sync staged from main"
    echo "5) 📝 Show Recent Commits"
    echo "6) 🔍 Compare staged vs main"
    echo "7) 🏥 Run Health Check"
    echo "8) 📋 Show Server URLs"
    echo "9) 🚪 Exit"
    echo ""
    read -p "Choose an option: " choice
}

# Option 1: Push to staging
push_to_staging() {
    print_header "Push to Staging"
    
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "staged" ]; then
        print_warning "You are on branch: $current_branch"
        read -p "Switch to staged branch? (y/n): " switch
        if [ "$switch" = "y" ]; then
            git checkout staged
            git pull origin staged
        else
            print_error "Please switch to staged branch first"
            return
        fi
    fi
    
    print_info "Current status:"
    git status -s
    
    if [ -z "$(git status -s)" ]; then
        print_warning "No changes to commit"
        return
    fi
    
    echo ""
    read -p "Commit message: " commit_msg
    
    if [ -z "$commit_msg" ]; then
        print_error "Commit message cannot be empty"
        return
    fi
    
    git add .
    git commit -m "$commit_msg"
    git push origin staged
    
    print_success "Pushed to staging!"
    print_info "GitHub Actions will automatically deploy to staging server"
    print_info "Check: https://github.com/Zulndra/Monitoring-System/actions"
    
    echo ""
    read -p "Open Actions page in browser? (y/n): " open_browser
    if [ "$open_browser" = "y" ]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "https://github.com/Zulndra/Monitoring-System/actions"
        elif command -v open &> /dev/null; then
            open "https://github.com/Zulndra/Monitoring-System/actions"
        else
            print_info "Please open manually: https://github.com/Zulndra/Monitoring-System/actions"
        fi
    fi
}

# Option 2: Promote to production
promote_to_production() {
    print_header "Promote to Production"
    
    echo "Choose method:"
    echo "a) Create PR via GitHub CLI (requires 'gh' installed)"
    echo "b) Get PR creation link (open in browser)"
    read -p "Choice (a/b): " method
    
    if [ "$method" = "a" ]; then
        if ! check_gh_cli; then
            return
        fi
        
        # Check if there are changes
        git fetch origin
        changes=$(git log origin/main..origin/staged --oneline | wc -l)
        
        if [ "$changes" -eq 0 ]; then
            print_warning "No changes to promote (staged is up to date with main)"
            return
        fi
        
        print_info "Changes to be promoted:"
        git log origin/main..origin/staged --oneline | head -10
        echo ""
        
        print_warning "This will create a Pull Request from staged to main"
        read -p "Continue? (y/n): " confirm
        
        if [ "$confirm" != "y" ]; then
            print_info "Cancelled"
            return
        fi
        
        # Create PR
        pr_title="🚀 Promote to Production - $(date +%Y-%m-%d)"
        pr_body="## Changes from Staging

$(git log origin/main..origin/staged --oneline | head -10)

## Checklist
- [ ] Tested in staging environment
- [ ] No critical bugs
- [ ] Health checks passed
- [ ] Ready for production

**Created by deploy.sh script**"

        gh pr create \
            --title "$pr_title" \
            --body "$pr_body" \
            --base main \
            --head staged \
            --label "deployment,production"
        
        print_success "Pull Request created!"
        print_info "Review and merge the PR to deploy to production"
        
    elif [ "$method" = "b" ]; then
        print_success "Open this link in your browser:"
        echo ""
        echo "  https://github.com/Zulndra/Monitoring-System/compare/main...staged"
        echo ""
        print_info "Then click 'Create pull request' button"
    else
        print_error "Invalid choice"
    fi
}

# Option 3: Check deployment status
check_status() {
    print_header "Deployment Status"
    
    if check_gh_cli; then
        print_info "Recent workflow runs:"
        gh run list --limit 10
        
        echo ""
        read -p "View details of a specific run? (run ID or press Enter to skip): " run_id
        
        if [ ! -z "$run_id" ]; then
            gh run view "$run_id"
        fi
    else
        print_info "GitHub CLI not installed. Open this link:"
        echo "  https://github.com/Zulndra/Monitoring-System/actions"
    fi
}

# Option 4: Sync staged from main
sync_staged() {
    print_header "Sync staged from main"
    
    print_warning "This will update staged branch with latest main branch"
    read -p "Continue? (y/n): " confirm
    
    if [ "$confirm" != "y" ]; then
        print_info "Cancelled"
        return
    fi
    
    git checkout staged
    git fetch origin
    git merge origin/main
    git push origin staged
    
    print_success "Staged branch synced with main!"
}

# Option 5: Show recent commits
show_commits() {
    print_header "Recent Commits"
    
    echo "=== Staged Branch (Staging) ==="
    git log origin/staged --oneline --decorate -5
    echo ""
    echo "=== Main Branch (Production) ==="
    git log origin/main --oneline --decorate -5
}

# Option 6: Compare branches
compare_branches() {
    print_header "Compare staged vs main"
    
    git fetch origin
    
    echo "=== Commits in staged but not in main ==="
    COMMITS=$(git log origin/main..origin/staged --oneline)
    
    if [ -z "$COMMITS" ]; then
        print_success "Staged and main are in sync!"
        return
    fi
    
    echo "$COMMITS"
    echo ""
    
    changes=$(echo "$COMMITS" | wc -l)
    print_info "Total commits ahead: $changes"
    
    if [ "$changes" -gt 0 ]; then
        echo ""
        read -p "Show detailed diff? (y/n): " show_diff
        if [ "$show_diff" = "y" ]; then
            git diff origin/main..origin/staged --stat
        fi
    fi
}

# Option 7: Run health check
run_health_check() {
    print_header "Health Check"
    
    if [ -f "health-check.sh" ]; then
        ./health-check.sh
    else
        print_error "health-check.sh not found!"
        print_info "Create it first or run health check manually on servers"
    fi
}

# Option 8: Show server URLs
show_urls() {
    print_header "Server URLs"
    
    echo "🖥️  Staging Server (98.87.60.46):"
    echo "  • Grafana:       http://98.87.60.46:3000"
    echo "  • Prometheus:    http://98.87.60.46:9090"
    echo "  • SNMP Exporter: http://98.87.60.46:9116"
    echo ""
    echo "🖥️  Production Server (98.87.83.12):"
    echo "  • Grafana:       http://98.87.83.12:3000"
    echo "  • Prometheus:    http://98.87.83.12:9090"
    echo "  • SNMP Exporter: http://98.87.83.12:9116"
    echo ""
    echo "🔗 GitHub:"
    echo "  • Repository:    https://github.com/Zulndra/Monitoring-System"
    echo "  • Actions:       https://github.com/Zulndra/Monitoring-System/actions"
    echo "  • Pull Requests: https://github.com/Zulndra/Monitoring-System/pulls"
}

# Main loop
main() {
    # Check if we're in git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository!"
        print_info "Please run this script from Monitoring-System directory"
        exit 1
    fi
    
    while true; do
        show_menu
        case $choice in
            1) push_to_staging ;;
            2|2a|2b) promote_to_production ;;
            3) check_status ;;
            4) sync_staged ;;
            5) show_commits ;;
            6) compare_branches ;;
            7) run_health_check ;;
            8) show_urls ;;
            9) 
                print_success "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main
main
