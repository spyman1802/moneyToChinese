create or replace function money2chinese(money in number) return varchar2 is
  v_str_yuan       varchar2(150);
  v_str_yuanfen    varchar2(152);
  v_len_yuan       number;
  v_len_yuanfen    number;
  v_result_yuan    varchar2(600);
  v_result_fen     varchar2(200);

  type type_map is table of varchar2(4) index by binary_integer;
  v_number_map     type_map;
  v_rmb_map        type_map;
  v_index          number;
  i                number;
  j                number;
  v_current_char   char(1);
begin
  if money is null then
    return null;
  end if;
  
  -- 输入金额四舍五入处理
  v_str_yuan := to_char(floor(money));
  
  if v_str_yuan = '0' then
    v_len_yuan := 0;
    v_str_yuanfen := lpad(to_char(floor(money * 100)), 2, '0');
  else
    v_len_yuan := length(v_str_yuan);
    v_str_yuanfen := to_char(floor(money * 100));
  end if;
  
  if v_str_yuanfen = '0' then
    v_len_yuanfen := 0;
  else
    v_len_yuanfen := length(v_str_yuanfen);
  end if;
  
  if v_len_yuan = 0 or v_len_yuanfen = 0 then
    return '零元整';
  end if;
  
  v_number_map(0) := '零';
  v_number_map(1) := '壹';
  v_number_map(2) := '贰';
  v_number_map(3) := '叁';
  v_number_map(4) := '肆';
  v_number_map(5) := '伍';
  v_number_map(6) := '陆';
  v_number_map(7) := '柒';
  v_number_map(8) := '捌';
  v_number_map(9) := '玖';
  v_rmb_map(-2) := '分';
  v_rmb_map(-1) := '角';
  v_rmb_map(1) := '';
  v_rmb_map(2) := '拾';
  v_rmb_map(3) := '佰';
  v_rmb_map(4) := '仟';
  v_rmb_map(5) := '万';
  v_rmb_map(6) := '拾';
  v_rmb_map(7) := '佰';
  v_rmb_map(8) := '仟';
  v_rmb_map(9) := '亿';
  
  -- 处理元
  for i in 1 .. v_len_yuan loop
    j            := v_len_yuan - i + 1;
    v_index := mod(i, 8);
    if v_index = 0 then
      v_index := 8;
    end if;
    if v_index = 1 and i > 1 then
      v_result_yuan := v_rmb_map(9) || v_result_yuan;
    end if;
    v_current_char := substr(v_str_yuan, j, 1);
    if v_current_char <> 0 then
      v_result_yuan := v_number_map(v_current_char) ||
                    v_rmb_map(v_index) || v_result_yuan;
    else
      if (i = 1 or i = 5) then
        if substr(v_str_yuan, j - 3, 4) <> '0000' then
          v_result_yuan := v_rmb_map(v_index) || v_result_yuan;
        end if;
      else
        if substr(v_str_yuan, j + 1, 1) <> '0' then
          v_result_yuan := v_number_map(v_current_char) || v_result_yuan;
        end if;
      end if;
    end if;
  end loop;
  
  -- 处理分
  if substr(v_str_yuanfen, -2, 2) <> '00' then
    if substr(v_str_yuanfen, -2, 1) = '0' then
      v_result_fen := '零';
    else
      v_result_fen := v_number_map(substr(v_str_yuanfen, -2, 1)) || '角';
    end if;
    
    if substr(v_str_yuanfen, -1, 1) <> '0' then
      v_result_fen := v_result_fen || v_number_map(substr(v_str_yuanfen, -1, 1)) || '分';
    end if;
  end if;
  
  if v_result_yuan is not null then
    v_result_yuan := v_result_yuan || '元';
  end if;
  if v_result_fen is null then
    v_result_yuan := v_result_yuan || '整';
  elsif substr(v_str_yuan, -1, 1) = '0' and substr(v_str_yuanfen, -2, 1) <> '0' then
    v_result_fen := '零' || v_result_fen;
  end if;

  return v_result_yuan || v_result_fen;
end;
