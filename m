Subject: Re: 2.6.0-test3-mm3
From: Gabor MICSKO <gmicsko@szintezis.hu>
In-Reply-To: <1061370505.510.3.camel@sunshine>
References: <20030819013834.1fa487dc.akpm@osdl.org>
	<1061370505.510.3.camel@sunshine>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Date: 20 Aug 2003 12:54:32 +0200
Message-Id: <1061376873.5331.9.camel@sunshine>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2003-08-19, k keltezessel Andrew Morton ezt irta:

> > 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test3/2.6.0-test3-mm3/
 

> Hi!
> 
> Compile error in drivers/media/video/tvmixer.c
> 
> 
> [...]
> 
>   CC [M]  drivers/media/video/tvmixer.o
> drivers/media/video/tvmixer.c: In function `tvmixer_clients':
> drivers/media/video/tvmixer.c:294: error: structure has no member named
> `name'
> drivers/media/video/tvmixer.c:294: error: structure has no member named
> `name'
> make[3]: *** [drivers/media/video/tvmixer.o] Error 1
> make[2]: *** [drivers/media/video] Error 2
> make[1]: *** [drivers/media] Error 2
> make: *** [drivers] Error 2



---------------------------------------------------------------------------


--- tvmixer.c   2003-08-09 06:40:55.000000000 +0200
+++ tvmixer.c_  2003-08-20 12:41:33.000000000 +0200
@@ -291,7 +291,7 @@
        devices[i].count = 0;
        devices[i].dev   = client;
        printk("tvmixer: %s (%s) registered with minor %d\n",
-              client->dev.name,client->adapter->dev.name,minor);
+              client->name,client->adapter->name,minor);

        return 0;
 }




-- 
Windows not found
(C)heers, (P)arty or (D)ance?
-----------------------------------
Micsko Gabor
Compaq Accredited Platform Specialist, System Engineer (APS, ASE)
Szintezis Computer Rendszerhaz Rt.      
H-9021 Gyor, Tihanyi Arpad ut 2.
Tel: +36-96-502-216
Fax: +36-96-318-658
E-mail: gmicsko@szintezis.hu
Web: http://www.hup.hu/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
