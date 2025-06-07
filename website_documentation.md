# Website Documentation

Hi! Welcome to the Documentation page of the "naturedreamwallpapers.com". If you are here, that means that either you're **setting up the website as an administrator, something bad happened with the website and it needs to be reconstructed, or you want to have an example of how to do a complete website hosted by IaaS, with a SSL certificate and a custom domain name**.

In all cases mentioned above, I will explain how to **fully (re)construct the website**, from starting your IaaS instance to website displaying.


## Launch a server instance with an IaaS provider (EC2)

First things first, for a website to be hosted on an IaaS provider, you actually need to choose a provider. I went with **AWS EC2**, a reliable option that proposes abordable prices for VM hosting.

After I made an account, I created an EC2 instance with the following specifications :

- OS : Ubuntu (x64/x86);
- Instance type : t3.micro;
- Key pair : (Create your own key pair);
- Security group : Create your own and tick the following boxes :
  - "Allow SSH traffic from : anywhere (0.0.0.0/0)";
  - "Allow HTTPS traffic from the internet";
  - "Allow HTTP traffic from the internet".

  **Note:** I decided to ignore the warning below the boxes for this website.
- Storage: 1x8 GiB gp3 Root volume, 3000 IOPS

Do not change anything for other options.
You can finally click on "Launch instance".

**Note:** Keep your ".pem" key in a known folder, it will be very important for the upcoming steps.


## Get your domain name and your SSL certificate (Cloudflare)

Once the instance is running, you want it to have "[https://naturedreamwallpapers.com](https://naturedreamwallpapers.com)", and not "http://bla.bla.bla.bla", as this is ugly, not explanatory of the project and, more importantly, **not secure**.
Therefore, you would want to have a **domain name** and a **SSL certificate**. Although these are **separate** steps, you can merge them by using Cloudflare, a well-trusted Domain Name Registrar, that, with roughly AU$10/year, will provide you **a ".com" domain name AND a SSL certificate**.

Note that if you want to lower your expenses, you can still select other domain name extensions, like ".fun" or ".io".
You can also have access to a **free SSL certificate** with Let's Encrypt for example. If you do that, **be VERY careful**.
If you are taking a free SSL certificate and then taking your domain name with Cloudflare for example, you will have **TWO SSL certificates**.
In most cases, **your website will not be displayed**, as the browser will not know which to trust.
The solution to that problem would be to simply **find a service that only provides a domain name**.

Here is the Cloudflare method :
- Create a Cloudflare account (or log into your account if it already exists).
- Search and click on "Register a domain". 
- Pay for the domain name.
- Search and click on "Connect a domain". 
- Copypaste your domain name on the searchbar.
- Create a DNS A record with your domain name and the IPv4 IP address of your EC2 instance.
- Your EC2 instance and your domain name and SSL certificate have been successfully linked!

You can now try and see if the link is established by entering your domain name into a web browser searchbar as Chrome.
You will see an error like "This site can't be reached.". Don't panic, this is because we havent touched the inside of our instance yet.
Just click on the bubble in the leftmost side of the web browser searchbar, and you will normally find your magnificent SSL certificate. That means everything is OK!


## Instance pre-processing

Next, we need to **initialize our HTTP server**, for our website to be rendered.
But first, we need to **enter our EC2 instance**. It is possible to do so by SSH.

Click into your EC2 instance, then click on "Connect", and find the SSH category.
Copy the command present at the bottom of the explanatory page. it should look like this:

`ssh -i [your_key].pem ubuntu@ec2-[your-public-ip-address]-[your-timezone]`

Now, open a terminal that allows Linux command executing. I personally use WSL, because my machine runs on Windows 11. Remember the ".pem" key you created with the instance? Go into the directory that contains your key, and paste the command you just copied, with the "sudo" keyword at the front:

`sudo ssh -i [your_key].pem ubuntu@ec2-[your-public-ip-address]-[your-timezone]`

After confirming the access, you will be logged into your EC2 machine. Good job!

Now, it is time to **install the HTTP server service** for our website. For this instance, I use Apache.
But right before that, let's install another package, PHP, that will be very useful for our future PHP file.
First, enter the following command:

```
sudo apt update   # to verify that every package is up-to-date
sudo apt install php libapache2-mod-php   # PHP Package
```

Then, enter the following line:

`sudo apt install apache2`

If there is no error, congrats: you just succeeded to install Apache!
You can now exit your instance for now, with the following word:

`exit`

Once it is done, you can **check if the Ubuntu default page displays on your computer**. Type your domain name into the web browser searchbar and, if everything is set up correctly, you will see a page named "**Ubuntu: It Works!**".
Nice job if you reached this point. Now begins the most interesting part.


## Sending website files into the instance

Because your computer and the instance are not the same machine, you **cannot directly move your files from your device to the instance**. However, there is a very powerful command that allows to send a file or a folder to a Web server: "scp" (for "Secure CoPy").

First, clone the repository of the website I made on [https://github.com/Unknono/NatureDreamWallpapers](https://github.com/Unknono/NatureDreamWallpapers) via HTTPS:

`git clone https://github.com/Unknono/NatureDreamWallpapers.git`

Or, if it doesn't work, by SSH:

`git clone git@github.com:Unknono/NatureDreamWallpapers.git`

Then, in your terminal, type the following command:

`sudo scp -ri [your_key].pem NatureDreamWallpapers/ ubuntu@[your_ip_address]:~/`

You can now log into your instance (here is the command so you don't have to search for it again):

`sudo ssh -i [your_key].pem ubuntu@ec2-[your-public-ip-address]-[your-timezone]`

Once logged in, move NatureDreamWallpapers/ to the HTML directory:

`sudo mv NatureDreamWallpapers/ /var/www/html`

We are almost done. Now, go to NatureDreamWallpapers/ into the HTML directory and copy these commands:

```
sudo mv index.html ..
sudo mv admin.html ..
sudo mv admin.php ..
sudo mv LICENSE ..
sudo mv README.md ..
sudo mv src/ ..
```

Then delete the NatureDreamWallpapers/ folder:

```
cd ..
sudo rm -r NatureDreamWallpapers/
```

We made it! Now our website should be displayed into the browser.
That's it people, you just made a website that is almost fully functioning. Wait... ALMOST functioning?
The website itself is functional, but there's one last thing we need to make functional: the "admin.html" page.


## Bash & PHP script adjustments

Right now, the "admin.html" page has several buttons that can do actions, like monitor, reboot, or even shutdown the server, when the provided password is the good one. However, **we still need permissions for the commands into bash scripts to be executed into the instance**. And for that, we will need to **modify the "sudoers" file**.
In your terminal, type:

`sudo visudo`

This will open the "sudoers" file. Scroll to the very bottom of the file, and write the following lines:

```
# naturedreamwallpapers.com utils
www-data ALL=(ALL) NOPASSWD: \
/var/www/html/src/bash/monitor.sh, \
/var/www/html/src/bash/reboot.sh, \
/var/www/html/src/bash/shutdown.sh
```

Finally, because we don't want the PHP and bash files to be modified by anybody, we want to **protect** them. Type:

```
sudo chown www-data:www-data /var/www/html/admin.php
sudo chown www-data:www-data /var/www/html/src/bash/*.sh
sudo chmod 700 /var/www/html/admin.php
sudo chmod 700 /var/www/html/src/bash/*.sh
```

Note that we still want to access to "admin.html" for monitoring purposes, which is why we modify no permissions and ownership for this file.


And now, we are definitely finished with the whole setup!
This took me a lot of time and, of course, trial and error, but this is the final result, and I'm proud of it. Note that **you can do the same thing with your own website**, and this will work perfectly fine too! I hope that this walkthrough will help people to understand how to host a website on IaaS, with a SSL certificate and a custom domain name.