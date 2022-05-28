pkgs: let
  awk = "${pkgs.gawk}/bin/awk";
  free = "${pkgs.procps}/bin/free";
  memory = pkgs.writeShellScript "memory" ''
    total="$(${free} -mh --si | grep Mem: | ${awk} '{ print $2 }')"
    used="$(${free} -mh --si | grep Mem: | ${awk} '{ print $3 }')"

    free=$(expr $total - $used)

    if [ "$1" = "total" ]; then
        echo $total
    elif [ "$1" = "used" ]; then
        echo $used
    elif [ "$1" = "free" ]; then
        echo $free
    elif [ "$1" = "percentage" ]; then
        printf '%.0f\n' $(${free} -m | grep Mem | ${awk} '{print ($3/$2)*100}')
    fi
  '';
in
  memory
