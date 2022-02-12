# frozen_string_literal: true

require './minruby'

str = minruby_load
text = minruby_parse(str)

def evaluate(tree, env)
  # litで始まっている場合は四則演算記号ではないの
  # かつ、節ではなく葉なので合計する必要ないためそのまま返す
  # それ以外は再起関数で繰り返し
  return tree[1] if tree[0] == 'lit'

  # 関数呼び出しの場合
  return p(evaluate(tree[2], env)) if tree[0] == 'func_call'
  # 複文の場合の処理
  return tree[1..].each{|branch| evaluate(branch, env)} if tree[0] == 'stmts'
  # 変数代入処理 -> ["var_assign", "x", ["lit", 1]]
  return env[tree[1]] = evaluate(tree[2], env) if tree[0] == 'var_assign'
  # 変数参照処理 -> ["var_ref", "x"] (var_ref時にはenvのキーを指定して返す)
  return env[tree[1]] if tree[0] == "var_ref"

  # 条件分岐処理
  # if のみ
  # note: caseb文はｍinrubyパーサーでifに置換されているので実装する必要がない。
  if tree[0] == "if"
    return evaluate(tree[1], env) ? evaluate(tree[2], env) : evaluate(tree[3], env)
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
  evaluate(tree[2], env) while evaluate(tree[1], env) if tree[0] == "while" or tree[0] == "while2"

  left = evaluate(tree[1], env)
  right = evaluate(tree[2], env)
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

evaluate(text, {})
