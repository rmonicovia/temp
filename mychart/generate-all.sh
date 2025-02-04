#!/usr/bin/bash

chart_path="$(dirname "$(realpath "$0")")"

query='select
    "project=" || p.name || 
    " ppath=" || p.path || 
    " envs=(base " || group_concat(e.name, " ") || ")" 
from 
    project p 
    left join environment e on 
        (p.name = e.project) 

where
    p.github_access 
    and p.kind="api" 

group by p.name 

limit 2'

IFS='
'

for vars in $(db run -nh "$query"); do
    eval "$vars"
    echo "Generating for project \"$project\", path=\"$ppath\""
    echo

    ## Testar
    cd "$ppath"
    git branch automigration master
    git worktree add ../automigration automigration

    cd ../automigration

    ppath="$(dirname "$ppath")/automigration"
    ## Testar

    cd "$chart_path"

    cp -r "$ppath/kustomize" source
    mkdir -p "$ppath/chart/overlays"

    for envr in ${envs[@]}; do
        echo "Generating for env \"$envr\""

        ./generate "$project" "$envr" \
        || {
            echo "Error running helm on project \"$project\" env \"$envr\"" 
            continue
        }

        if [ "$envr" == "base" ]; then
            dest="$ppath/chart/values.yaml"
        else
            dest="$ppath/chart/overlays/values-$envr.yaml"
        fi
        
        cp output/mychart/templates/chart/values.yaml "$dest"
    done

    # cp templates
    # cp output/Chart.yaml source/chart
    # cp viaops.yaml
    #
    rm -rf source 

    cd "$ppath"

    git add -A

    git commit --message "feat(CMOB-2670): esteiras migradas"
done
