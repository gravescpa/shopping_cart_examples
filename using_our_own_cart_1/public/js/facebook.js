   window.fbAsyncInit = function() {
            FB.init({
              appId      : '609455592567308', // Set YOUR APP ID
              channelUrl : '', // Channel File
              status     : true, // check login status
              cookie     : true, // enable cookies to allow the server to access the session
              xfbml      : true  // parse XFBML
            });
            FB.Event.subscribe('auth.authResponseChange', function(response) 
            {
             if (response.status === 'connected') 
            {
                // document.getElementById("message").innerHTML +=  "<br>Connected to Facebook";
                console.log("Connected to Facebook");  
                //SUCCESS
            }    
            else if (response.status === 'not_authorized') 
            {
                document.getElementById("message").innerHTML +=  "<br>Failed to Connect";
                //FAILED
            } else 
            {
                document.getElementById("message").innerHTML +=  "<br>Logged Out";
                //UNKNOWN ERROR
            }
            }); 
            };
            function Login()
            {
                FB.login(function(response) {
                   if (response.authResponse) 
                   {
                       FB.api('/me?fields=id, name, email', function(response) {
                        var name = response.name;
                        var email = response.email;
    
                        $('input[name="name"]').attr("value", name);
                        $('input[name="email"]').attr("value", email);   
                        $("#facebook_login").submit(); 
                       });
                       // window.location = "";
                        // console.log(response);
                    } else 
                    {
                     console.log('User cancelled login or did not fully authorize.');
                    }
                 },{scope: 'public_profile, email'});
            }
          function getUserInfo() {
                FB.api('/me', function(response) {
              var str="<b>Name</b> : "+response.name+"<br>";
                  str +="<b>Link: </b>"+response.link+"<br>";
                  str +="<b>Username:</b> "+response.username+"<br>";
                  str +="<b>id: </b>"+response.id+"<br>";
                  str +="<b>Email:</b> "+response.email+"<br>";
                  str +="<input type='button' value='Logout' onclick='Logout();'/>";
                  document.getElementById("status").innerHTML = str;
                  
            });
            }
            function getPhoto()
            {
              FB.api('/me/picture?type=normal', function(response) {
                  var str="<br/><b>Pic</b> : <img src='"+response.data.url+"'/>";
                  document.getElementById("status").innerHTML+=str;
            });
            }
            function Logout()
            {
                FB.logout(function(){document.location.reload();});
            }
          // Load the SDK asynchronously
          (function(d){
             var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
             if (d.getElementById(id)) {return;}
             js = d.createElement('script'); js.id = id; js.async = true;
             js.src = "https://connect.facebook.net/en_US/all.js";
             ref.parentNode.insertBefore(js, ref);
           }(document));