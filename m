Date: Thu, 7 Jun 2001 20:34:24 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM Report was:Re: Break 2.4 VM in five easy steps (fwd)
Message-ID: <Pine.LNX.4.21.0106072033260.1156-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Shane Nay <shane@minirl.com>
List-ID: <linux-mm.kvack.org>

First report of better interactivity under high VM loads with the vm-mt
patch against 2.4.6-pre1. 

---------- Forwarded message ----------
Date: Thu, 7 Jun 2001 17:41:47 -0700
From: Shane Nay <shane@minirl.com>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM Report was:Re: Break 2.4 VM in five easy steps


>
> Could you please try
> http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.6pre1/2.4.6pre1-vm-
>mt.patch and tell me if interactivity gets better?
>
> Thanks a lot!

Okay, I tried 2.4.6pre1 plus the patch that you point to here.  Good and bad 
news.  The bad news is I couldn't replicate my normal working enviroment 
because the NVidia module blew up on insertion into the kernel.  (I think 
some symbol mangling thing..., not sure, didn't look at too too closely)

Anyway, so what I did instead was run my contrived tests in console mode 
under both different versions several times.  And here is where the good news 
comes in.  Yes, the 2.4.6pre1 plus the patch you sent does make the machine 
much more "interactive" during high memory pressure/VM stress.  What happened 
a couple times with 2.4.5 was that it literally hung half way through trying 
to run the shell util free for a quite noticable amount of time, delaying 
keyboard output to screen during that period at the console.  I repeated the 
tests under the same precise conditions with 2.4.6pre1 but could not get it 
to exhibit the same broken behaviour.

The only thing that bugged me about 2.4.6pre1 + your patch's VM is that it 
makes pretty broken choices as to what to OOM kill..., but I realize this is 
a point of great controversy.  (It killed identd with great frequency for 
some reason)  Anyway, the same is true of 2.4.5, it made what looked like the 
same choices.  (But I didn't write that information down)  It was quite happy 
with minimizing the cache, which 2.4.5 under console did as well.  But 2.4.5s 
minimizing of the cache seemed to be what sort of started the slow down of 
interactivity.

Thank You,
Shane Nay.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
