Message-ID: <3D77ED4D.B5C92504@zip.com.au>
Date: Thu, 05 Sep 2002 16:48:29 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
References: <E17n25p-0006AQ-00@starship> <1031269130.5760.318.camel@tux>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Cc: Daniel Phillips <phillips@arcor.de>, Steven Cole <elenstev@mesatop.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Josefsson wrote:
> 
> On Thu, 2002-09-05 at 21:15, Daniel Phillips wrote:
> > On Thursday 05 September 2002 19:23, Steven Cole wrote:
> > > I booted 2.5.33-mm3 and ran dbench with increasing
> > > numbers of clients: 1,2,3,4,6,8,10,12,16,etc. while
> > > running vmstat -n 1 600 from another terminal.
> > >
> > > After about 3 minutes, the output from vmstat stopped,
> > > and the dbench 16 output stopped.  The machine would
> > > respond to pings, but not to anything else. I had to
> > > hard-reset the box. Nothing interesting was saved in
> > > /var/log/messages. I have the output from vmstat if needed.
> >
> > That happened to me yesterday while hacking 2.4 and the reason was
> > failed oom detection.  Memory leak?
> 
> I've seen this on 6 diffrent machines (master.kernel.org is one of
> them). I have a fileserver here that hits this all the time, sometimes
> as much as a few times a day.
> 

What have you seen?  I doubt if it's a memory leak - they tend to
be preceded by a very obvious swapstorm.

It seems that you have boxes which lock up, and we have no more info
than that.

If the machine remains pingable then yes, it may be a VM deadlock/livelock.
We'd need to know the kernel version, system description, and a SYSRQ-T
trace passed through ksymoops would be helpful.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
