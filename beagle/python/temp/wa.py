def find_odd(start, end):
  print "Start is ", start
  print "End is ", end
  for num in range(start, end):
    if num % 2 == 1:
      print num