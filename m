Message-ID: <170EBA504C3AD511A3FE00508BB89A920234CD4F@exnanycmbx4.ipc.com>
From: "Downing, Thomas" <Thomas.Downing@ipc.com>
Subject: RE: 2.6.0-test1-mm1
Date: Sun, 20 Jul 2003 14:50:40 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andrew Morton' <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: Andrew Morton [mailto:akpm@osdl.org]
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/
> 2.6.0-test1/2.6.0-test1-mm1/
> 
> . Lots of bugfixes.
> . Another interactivity patch from Con.  Feedback is needed on this
>   please - we cannot make much progress on this fairly subjective work
>   without lots of people telling us how it is working for them.
> 

I have been testing interactivity now for for a while.  The only
symptom (subjective) that I can see is occasional but repeatable
(if you get what I mean) video _only_ skips in xine.  The audio
does not skip.  The video skips are very short, only a 4-5 frames
at most.

They occur _only_ when performing such operations as rendering a 
large bitmap to the screen.  They do _not_ occur when dragging
windows (with contents visible during drag,) nor does CPU load
seem to have an effect.

Playing games with nice/renice on xine or on other processes,
especially GIMP etc., does not seem to have an effect.  

>From this it seems to my limited view that the remaining skips
might be XFree86 issues?

Some pertinent details:

2 x P4 Xeon 2.4 Mhz, 512Mb ram.
Radeon VQ + Matrox Mystique.
Premptive kernel
Hyperthreading enabled.
IDE DVD, no SCSI in system.

No problems at all, only minor niggles since 2.5.67.  (I have
been following -mm patches.)

Thanks for the wonderful work!

td
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
