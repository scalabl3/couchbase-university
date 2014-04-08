// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require persona
//= require_tree .

$( document ).ready(function() {
  
	$(document).keydown(function (e) {    
    if (e.which === 102 && (e.ctrlKey || e.metaKey)) { // Ctrl/Cmd + f
        console.log("yo!");
        return false;
    }
	});
	
  $('#signin').modal({
    show: false,
		keyboard: true
  });

  $('#signin-link').click(function(e){
     e.preventDefault();
     $('#signin').modal('toggle');
  });

	$('#signin-link-sm').click(function(e){
     e.preventDefault();
     $('#signin').modal('toggle');
  });
  
	$('#persona-signin').click(function(e){
		e.preventDefault();
		$('#signin').modal('toggle');
		navigator.id.request({siteName: 'Couchbase University' }); //, siteLogo: '/assets/couchbase_small_gradient.png'});
	});
	
	$('#signout-link').click(function(e){
		e.preventDefault();
		$.ajax({
			url: "/logout"
		}).done(function() {
		  window.location.reload();
		});
		navigator.id.logout();
  });

	navigator.id.watch({
	  loggedInUser: personaEmail,
	  onlogin: function(assertion) {
	    // A user has logged in! Here you need to:
	    // 1. Send the assertion to your backend for verification and to create a session.
	    // 2. Update your UI.
	    $.ajax({ /* <-- This example uses jQuery, but you can use whatever you'd like */
	      type: 'POST',
	      url: '/persona/login', // This is a URL on your website.
	      data: {assertion: assertion},
	      success: function(res, status, xhr) { window.location.reload(); },
	      error: function(xhr, status, err) {
	        navigator.id.logout();
	        console.log("Login failure: " + err);
	      }
	    });
	  },
	  onlogout: function() {
	    // A user has logged out! Here you need to:
	    // Tear down the user's session by redirecting the user or making a call to your backend.
	    // Also, make sure loggedInUser will get set to null on the next page load.
	    // (That's a literal JavaScript null. Not false, 0, or undefined. null.)
	    $.ajax({
	      type: 'POST',
	      url: '/persona/logout', // This is a URL on your website.
	      success: function(res, status, xhr) {  },
	      error: function(xhr, status, err) { console.log("Logout failure: " + err); }
	    });
	  }
	});
  
});

