Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
Date: Fri, 6 Sep 2002 02:02:57 +0200
References: <1031246639.2799.68.camel@spc9.esa.lanl.gov> <E17n25p-0006AQ-00@starship> <1031269130.5760.318.camel@tux>
In-Reply-To: <1031269130.5760.318.camel@tux>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17n6aP-0006Cw-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Cc: Steven Cole <elenstev@mesatop.com>, Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 06 September 2002 01:38, Martin Josefsson wrote:
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
> If anyone has any ideas or patches for 2.4 I'll happily test them.

I'd like to be able to say "just enable kdb under kernel debugging
and we'll see where it's stuck next time it's stuck".  Unfortunately,
I'm going to have to replace that with "go get the patch from sgi
if there is a current one and figure out how to install it".

Or maybe, "let's mess around with Alt-SysRq and write down funny
numbers on a piece of paper, type them into a file and run ksymoops
on them."  Nope, sorry, life is too short for that.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
