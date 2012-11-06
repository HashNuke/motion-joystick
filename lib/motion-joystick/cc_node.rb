class CCNode
  def scaledSize
    cs = self.contentSize
    CGSizeMake(cs.width * self.scaleX, cs.height * self.scaleY)
  end
end
