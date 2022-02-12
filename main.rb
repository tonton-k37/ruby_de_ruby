# frozen_string_literal: true

require './minruby'

str = minruby_load
text = minruby_parse(str)

def evaluate(tree, genv, lenv)
  # litで始まっている場合は四則演算記号ではないの
  # かつ、節ではなく葉なので合計する必要ないためそのまま返す
  # それ以外は再起関数で繰り返し
  return tree[1] if tree[0] == 'lit'

  # ユーザー定義関数処理
  # tree => 関数名, tree2 => 仮引数名の配列, tree3 => 関数本体
  return genv[tree[1]] = ["user_defined", tree[2], tree[3]] if tree[0] == "func_def"

  # 関数呼び出しの場合
  # i + 2の理由としては構文木の構成で、指定した引数（以下の場合p)の次に来る値を評価したい為
  # ["func_call", "p", ["lit", 1], ["lit", 2]]
  if tree[0] == "func_call"
    # 実引数をargsに代入
    args = tree[2..].map{|item| evaluate(item, genv, lenv)}
    mhd = genv[tree[1]]
    if mhd[0] == "builtin"
      return send(mhd[1], *args)
    else
      # ユーザー定義関数時の処理
      scoped_lenv = mhd[1].map.with_index{|param, index| [param, args[index]]}.to_h
      return evaluate(mhd[2], genv, scoped_lenv)
    end
  end


  # return p(evaluate(tree[2], genv, lenv)) if tree[0] == 'func_call'
  # 複文の場合の処理
  return tree[1..].each{|branch| evaluate(branch, genv, lenv)} if tree[0] == 'stmts'
  # 変数代入処理 -> ["var_assign", "x", ["lit", 1]]
  return lenv[tree[1]] = evaluate(tree[2], genv, lenv) if tree[0] == 'var_assign'
  # 変数参照処理 -> ["var_ref", "x"] (var_ref時にはenvのキーを指定して返す)
  return lenv[tree[1]] if tree[0] == "var_ref"

  # 条件分岐処理
  # if のみ
  # note: caseb文はｍinrubyパーサーでifに置換されているので実装する必要がない。
  if tree[0] == "if"
    return evaluate(tree[1], genv, lenv) ? evaluate(tree[2], genv, lenv) : evaluate(tree[3], genv, lenv)
  end
  
  # ループ文
  # memo: 事前にhashに0が代入されているので、while句の後の評価が実行できている
  <<-DOC
  ["stmts",
    ["var_assign", "i", ["lit", 0]],
    ["while",
    ["<", ["var_ref", "i"], ["lit", 10]],
    ["stmts",
    ["func_call", "p", ["var_ref", "i"]],
    ["var_assign", "i", ["+", ["var_ref", "i"], ["lit", 1]]]]]]    
  DOC
  evaluate(tree[2], genv, lenv) while evaluate(tree[1], genv, lenv) if tree[0] == "while" or tree[0] == "while2"

  # 配列構築子
  <<-DOC
  ["stmts",
    ["var_assign", "ary", ["ary_new", ["lit", 1]]],
    ["ary_ref", ["var_ref", "ary"], ["lit", 0]]]    
  DOC
  return  tree[1..].map{|value| evaluate(value, genv, lenv)} if tree[0] == "ary_new"
  # 配列参照
  if tree[0] == "ary_ref"
    # 参照したい配列をaryで取得
    # indexで指定したい位置を指定
    ary = evaluate(tree[1], genv, lenv)
    index = evaluate(tree[2], genv, lenv)
    return ary[index]
  end
  # 配列代入
  if tree[0] == "ary_assign"
    # 新しく渡したい値を評価して代入
    ary = evaluate(tree[1], genv, lenv)
    index = evaluate(tree[2], genv, lenv)
    new_value = evaluate(tree[3], genv, lenv)
    return ary[index] = new_value
  end

  # hash
  if tree[0] == "hash_new"
    hsh = tree[1..].each_slice(2).map do |item|
      [evaluate(item[0], genv, lenv), evaluate(item[1], genv, lenv)]
    end.to_h

    return hsh
  end

  left = evaluate(tree[1], genv, lenv)
  right = evaluate(tree[2], genv, lenv)
  begin
    case tree[0]
    when '+'
      left + right
    when '-'
      left - right
    when '*'
      left * right
    when '/'
      left / right
    when '%'
      left % right
    when '**'
      left**right
    when '<'
      left < right
    when '>'
      left < right
    when '<='
      left <= right
    when '>='
      left >= right
    when '=='
      left == right
    when '!='
      left != right
    when '<=>'
      left <=> right
    when '==='
      left === right
    end
  rescue StandardError => e
    puts 'Oh my goooooood :X'
  end
end

genv = {
  "p" => ["builtin", "p"],
  "require" => ["builtin", "require"],
  "minruby_parse" => ["builtin", "minruby_parse"],
  "minruby_load" => ["builtin", "minruby_load"],
  "minruby_call" => ["builtin", "minruby_call"],
}

lenv = {}
evaluate(text, genv, lenv)
