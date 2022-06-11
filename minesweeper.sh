#!/bin/bash
function draw_field () {
	#Рисует поле, видимое игроку
   echo '     A   B   C   D   E   F   G   H'
   echo ------------------------------------
      for row in {0..7}
         do
	    let "n_row=row+1"
            echo -n $n_row ' |'
	    for column in {0..7}
	       do
		  let "ind=row*8+column"
		  echo -n ' '${closed_field[$ind]}' |'
	  done
	    echo
	    echo ------------------------------------
	done
}
function draw_closed_field () {
	#Рисует открытое поле
   echo '     A   B   C   D   E   F   G   H'
   echo ------------------------------------
      for row in {0..7}
         do
	    let "n_row=row+1"
            echo -n $n_row ' |'
	    for column in {0..7}
	       do
		  let "ind=row*8+column"
		  echo -n ' '${field[$ind]}' |'
	  done
	    echo
	    echo ------------------------------------
	done
}
function read_input () {
	#Считывает со стандартного ввода комманду и ячейку
   read input
   command=${input%% *}
      if [[ $command = "exit" ]]
      then
	     exit 0
     fi 
   ind=${input##* }
   letter_in_col=${ind:0:1}
   input_row=${ind:1:1}
   let "input_row=$input_row-1"
   if [[ $input_row -gt 7 ]] || [[ $input_row -lt 0 ]] 
   then
	   read_input
   fi
   case "$letter_in_col" in
      A) input_col=0;;
      B) input_col=1;;
      C) input_col=2;;
      D) input_col=3;;
      E) input_col=4;;
      F) input_col=5;;
      G) input_col=6;;
      H) input_col=7;;
      * ) echo 'Введите верную команду'
	  read_input;;
   esac 
   if [[ "$command" = "FL" ]] 
   then
	   let "inp_ind=$input_row*8+$input_col"
           closed_field[$inp_ind]="F"
   fi
   if [[ "$command" = "UNFL" ]] 
   then
	   let "inp_ind=$input_row*8+$input_col"
	   if [[ ${closed_field[$inp_ind]} = "F" ]]
	   then
		   closed_field[$inp_ind]="."
	   fi
   fi

}
function open_cell () {
	#Открывает выбранные ячейки
   let "cell_index=$2 * 8 + $1"
   declare -a near_zero_cell
   if [[ ${field[$cell_index]} = 'X' ]]
   then
	   closed_field[$cell_index]='X'
           draw_closed_field
	   echo Вы проиграли
	   exit 0
   fi
   if [[ ${field[$cell_index]} -eq 0 ]]
   then
	 closed_field[$cell_index]=0
         let "near_zero_cell[0]=$cell_index-1"
         let "near_zero_cell[1]=$cell_index+1"
         let "near_zero_cell[2]=$cell_index-7"
         let "near_zero_cell[3]=$cell_index-8"
         let "near_zero_cell[4]=$cell_index-9"
         let "near_zero_cell[5]=$cell_index+7"
         let "near_zero_cell[6]=$cell_index+8"
         let "near_zero_cell[7]=$cell_index+9"
	 for i in ${near_zero_cell[*]}
	 do
   	       let "row = $i / 8"       
	       let "column = $i - $row * 8"
	       let "row_dif = $row - $2"
	       let "column_dif = $column - $1"
	       row_dif=${row_dif#-}
	       column_dif=${column_dif#-}
	       if [[ ($row_dif -le 1) ]] && [[ ($column_dif -le 1) ]] && [[ $i -ge 0 ]] && [[ $i -le 63 ]] 
               then
		       if [[ "${closed_field[$i]}" = "." ]] || [[ "${closed_field[$i]}" = "F" ]]
		       then
			       if [[ ${field[$i]} -ne 0 ]]
		               then
			       closed_field[$i]=${field[$i]}
		               else
			       closed_field[$i]=0
                               open_cell "$column" "$row"
		               fi
		       fi	       
	       fi
	done
   else
      closed_field[$cell_index]=${field[$cell_index]}	   
   fi
}
declare -a field
declare -a closed_field
declare -a near_mines_index
for index in {0..63}
   do
      field[$index]=0
   done
for index in {0..63}
   do
      closed_field[$index]='.'
   done
for mine_num in {1..8} #Заполняем поле минами и числами
   do
      let "rand_num=1 + $RANDOM % 64"
      while [[  ${field[$rand_num]} = 'X'  ]]
         do
            let "rand_num=$RANDOM % 64"
         done
	 field[$rand_num]='X'
	 let "start_row=$rand_num / 8"
	 let "start_column=$rand_num - $start_row * 8"
         let "near_mines_index[0]=$rand_num-1"
         let "near_mines_index[1]=$rand_num+1"
         let "near_mines_index[2]=$rand_num-7"
         let "near_mines_index[3]=$rand_num-8"
         let "near_mines_index[4]=$rand_num-9"
         let "near_mines_index[5]=$rand_num+7"
         let "near_mines_index[6]=$rand_num+8"
         let "near_mines_index[7]=$rand_num+9"
	 for near_mine in ${near_mines_index[*]}
            do
   	       let "row = $near_mine / 8"       
	       let "column = $near_mine - $row * 8"
	       let "row_dif = $row - $start_row"
	       let "column_dif = $column - $start_column"
	       row_dif=${row_dif#-}
	       column_dif=${column_dif#-}
	       if [[ (${field[$near_mine]} != 'X') ]] && [[ ($row_dif -le 1) ]] && [[ ($column_dif -le 1) ]]
	       then
		       let field[$near_mine]++
	       fi
            done   
   done
echo "!!!Инструкция!!!"
echo "Способ ввода команды: [команда] [ячейка]"
echo "Виды команд:"
echo "OP - открыть ячейку"
echo "FL - поставить флажок"
echo "UNFL - убрать флажок"
echo "exit - выйти из игры"
echo "Пример команды: OP B7"
draw_field
while [[ 1 ]] 
   do
      read_input
      if [[ $command = "OP" ]] 
      then
      	open_cell "$input_col" "$input_row"
	opened=0
	for rem in {0..63}
	do
           if [[ ${closed_field[$rem]} != "." ]] && [[ ${closed_field[$rem]} != "F" ]]
	   then
		   let "opened=${opened}+1"
	   fi
        done
	if [[ $opened -ge 56 ]]
	then
		draw_field
		echo "Вы победили"
		exit 0
        fi
      fi 
      draw_field
   done      
