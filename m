Message-ID: <170EBA504C3AD511A3FE00508BB89A920221E6EA@exnanycmbx4.ipc.com>
From: "Downing, Thomas" <Thomas.Downing@ipc.com>
Subject: RE: 2.5.70-mm2
Date: Thu, 29 May 2003 15:08:35 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I use MySQL pretty extensively, so I'll excersize that as well as
the day-to-day builds, etc.  I'm on day 4 of -mm1, no problems to date.

By definition, I'm happy!

-----Original Message-----
From: Andrew Morton [mailto:akpm@digeo.com]
Sent: Thursday, May 29, 2003 1:36 PM
To: Downing, Thomas
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: Re: 2.5.70-mm2


"Downing, Thomas" <Thomas.Downing@ipc.com> wrote:
>
> -----Original Message-----
> From: Andrew Morton [mailto:akpm@digeo.com]
> 
> >
>
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-
> mm2/
> [snip]
> >  Needs lots of testing.
> [snip]
> 
> I for one would like to help in that testing, as might others.
> Could you point to/name some effective test tools/scripts/suites 
> for testing your work?  As it is, my testing is just normal usage,
> lots of builds.
> 

I was specifically referring to the O_SYNC changes there.  That means
databases: postgresql, mysql, sapdb, etc.

Some of these use fsync()-based synchronisation and won't benefit, but they
may have compile-time or runtime options to use O_SYNC instead.


Apart from that, just using the kernel in day-to-day activity is the most
important thing.  If everyone does that, and everyone is happy then by
definition this kernel is a wrap.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
