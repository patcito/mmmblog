function allTags(q) {
  var counts = db.eval(
    function(q){
      var tags = [];
      db.posts.find(q).forEach(
        function(p){
          if(p.tags){
            p.tags.forEach(
              function(tag){
                var notThere = true
                tags.forEach(
                  function(t){
                    if(t==tag){ notThere = false}
                  }
                )
                if(notThere)
                  tags.push(tag);
              }
            )
          }
        }
      )
      return tags;
    }
  )
  return counts;
}