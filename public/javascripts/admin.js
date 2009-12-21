$('document').ready(function(){
  $('.delete').click(function(){
    var deletec = confirm('Are you sure?');
    var deleteLink = this;

    if(deletec){
      $.post(this.href, { _method: 'delete' }, function(){$(deleteLink).parent('li').remove();});
      return false;
    } else {return false;}
  })
})