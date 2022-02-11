# frozen_string_literal: true

def max(tree)
  # 最大値を再帰的に取得する
  return tree[1] if tree[0] == 'lit'

  left = max(tree[1])
  right = max(tree[2])

  left > right ? left : right
rescue StandardError => e
  puts 'Oh my gooooooooood'
end

max_value = max(text)
print(max_value)
