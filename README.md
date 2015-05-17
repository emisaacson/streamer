Streamer v0.1
=============

This is a cloudformation template to launch a stack into AWS EC2 to live-stream video to the web.

Features
--------

* Transcode a live RTMP stream into formats that every modern device can consume, including:
  * RTMP (flash / desktop)
  * HLS in 3 bandwidths - hi, med, low (iOS)
  * WebM (Android, others)

* Good scalability out of the box, by default uses two servers per video protocol to for clients
to consume the stream.

* (Almost) no configuration required to get started thanks to the magic of Salt.

* Configured to use RMTP over port 80 to avoid firewall issues.

* Client side code included that can be copy pasted to any site.

* Optional Google Analytics integration.

* Only the initial security and Salt Master resource are created with Cloudformation, which should
make porting this to some provider other than AWS that salt-cloud supports not too difficult.

Not Features
------------

* You need to fork this repo and manually change configuration files if you want a different stack
than you get out of the box (but it's not hard).

* Not efficient. The main transcoding server is HUGE and runs a couple hundred threads of FFMPEG
simultaneously. If you're broadcasting an event for a couple hours it won't cost more than a few 
dollars but in the name of all that is holy do not forget to turn these servers off when you are
not using them or your next AWS bill will be a nasty surprise.

* Does not do any recording of the stream out of the box. You can configure this yourself.

* Does not authenticate incoming streams. You need to configure this yourself too if you want it.

* Only supports one stream out of the box. You can configure it yourself to do more than one.

* Region and AZ not parameterized. It uses us-east-1a. This would be really easy to do but I haven't
had time yet to test it. Coming soon.

The Perfect Use Case For Out Of The Box Configuration
-----------------------------------------------------

You should be able to plug and play if your scenario matches this:


* You want to broadcast a single live video stream to a few hundred, maybe up to couple thousand
consumers (you'll need to do your own load testing if you need it).

* You want it to work on any device.

* The event doesn't go on forever, or your budget is unlimited.


Instructions
------------

1. Get an AWS account. You probably want to ask for an increase in Elastic IP addresses to at least
6 (the default is 5 and this stack needs 6). Make sure there's a default subnet in US East 1a.

2. Create an AWS keypair and API key.

3. Upload the included cloudformation.template file to Cloudformation. Enter the AMI id you want to use.
It should be Debian / Wheezy, AMD64, and Paravirtual. ami-baeda9d2 at the time of this writing is
a good choice. Debian / Jessie might work also but is not tested.

4. OPTIONALLY, input your key name, your API id and key, and the contents of your private key as parameters.
For better security but no plug and play, leave all the parameters blank. You will have to upload
the information yourself (see next step).

5. Skip this step if you inputted the parameters in step 4. If you did not, the deployment process
will stop after the Salt Master machine is created. SSH into the Salt Master
and place your key file in the location `/etc/salt/KEYPAIR.pem`. Then make it read-only via

```
    sudo chown root:root /etc/salt/KEYPAIR.pem
    sudo chmod 400 /etc/salt/KEYPAIR.pem
```

  Finally, run this command to finish deployment:

```
    sudo bash /opt/stack/scripts/bootstrap/bootstrap_salt_stack.sh "MyKeypairName" "MyApiId" "MyApiKey"
```

  There are other ways to get the private key to the cloud. In my personal environment I have the
  key information available on a server at home that is only available to the Salt Master
  in a private VPC subnet on AWS that is not routable from the internet. There's an IPSec VPN
  connection between them and for my purposes that's a secure enough way to transfer the key
  information without manual steps.

6. To take advantage of DNS load balancing, set the following DNS entries:

  * CNAME or A rtmp.example.com for the machines rtmp01 and rtmp02
  * CNAME or A hls.example.com for the machines hls-dash01 and hls-dash02
  * CNAME or A webm.example.com for the machines stream-m01 and stream-m02

  In my personal environment setting these entries is part of the deployment script since the
  zones are hosted on Route 53.

7. You need a way to upload your video to the media server. If using Android, try
arutcam. There are similar options for iOS but I can't recommend one. Configure arutcam
or your app of choice to hit rtmp://my-domain-or-ip.com:80/live/feed. Start broadcasting!

8. All the client side code is in the `client` directory. You should open up index.html and read
through that file to set your values accordingly. You will need to enter your various domains
for streams and GA Account ID if you want to. Also you will need a JWPlayer license, which you can
get for free from http://www.jwplayer.com/. (Flowplayer is used for HTML5 video and JWPlayer for
RTMP/Flash, because Flowplayer has some issues with RTMP streams from nginx-rtmp.)
