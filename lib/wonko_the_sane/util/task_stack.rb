class TaskStack
  @@queue = []
  def self.push(task)
    @@queue.push task
  end
  def self.push_defered(task)
    @@queue.unshift task
  end
  def self.pop
    task = @@queue.pop
    task.call
  end
  def self.pop_all
    self.pop until @@queue.empty?
  end
  def self.in_background(&block)
    thread = Thread.new &block
    TaskStack.pop_all
    thread.join
  end
end
