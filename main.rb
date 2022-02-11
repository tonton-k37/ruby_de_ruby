# frozen_string_literal: true

require './minruby'

text = minruby_parse('(1 + 2) + 3 + 4')

pp(text)

def evaluate(tree)
  # litで始まっている場合は四則演算記号ではないの
  # かつ、節ではなく葉なので合計する必要ないためそのまま返す
  # それ以外は再起関数で繰り返し

  return tree[1] if tree[0] == 'lit'

  left = evaluate(tree[1])
  right = evaluate(tree[2])
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
    else # ===
      left === right
    end
  rescue StandardError => e
    puts 'Oh my goooooood :X'
  end
end

result = evaluate(text)
puts(result)

def max(tree)
  # 最大値を再帰的に取得する
  return tree[1] if tree[0] == 'lit'

  left = max(tree[1])
  right = max(tree[2])

  left > right ? left : right
rescue StandardError => e
  puts e
end

max_value = max(text)
print(max_value)
