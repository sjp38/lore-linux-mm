Message-ID: <170EBA504C3AD511A3FE00508BB89A920234CD4A@exnanycmbx4.ipc.com>
From: "Downing, Thomas" <Thomas.Downing@ipc.com>
Subject: RE: 2.6.0-test1-mm1
Date: Thu, 17 Jul 2003 07:57:38 -0400
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
> 
> . A big one-liner from Mark Haverkamp fixes some hanges which 
> were being
>   seen with the aacraid driver and may fix the problem which 
> people have seen
>   on other SCSI drivers: everything getting stuck in 
> io_schedule() under load.
> 
> . Another interactivity patch from Con.  Feedback is needed on this
>   please - we cannot make much progress on this fairly subjective work
>   without lots of people telling us how it is working for them.

I have been testing 2.5.75-mm1.  I was able to cause video skip in xine,
but not audio.  I will repeat the tests using test1-mm1.  Anyone else
seen the video-only type skip?  It appears to be caused by other GUI
operations, not so much by CPU load.  Just dragging windows is not enough,
it needs to be more intensive than that.

More results later with test1-mm1

Thanks for all the great stuff!!

td
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
