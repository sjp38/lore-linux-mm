Received: from ucla.edu (ts16-70.dialup.bol.ucla.edu [164.67.26.79])
	by caracal.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id KAA18875
	for <linux-mm@kvack.org>; Wed, 18 Jul 2001 10:39:07 -0700 (PDT)
Message-ID: <3B55C972.6060702@ucla.edu>
Date: Wed, 18 Jul 2001 10:37:54 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Remaining MM problems/fixes for 2.4?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

First of all, thanks a lot for all the hard work that you guys have put 
into this, Rik, Marcello, and others!

Basically, the 2.4 VM has some nice features, but seems to have enough 
trouble keeping the right pages in memory to give smooth interactive.

1.  Page's aged down too rapidly

Can anyone confirm this?  This may be a result of the current kernel's 
use of >> for aging pages down - I think Rik said something to this 
effect.  In any case, the kernel OFTEN does page-ins on my 64MB system 
when I'm not really running that much.  For example, if I refresh a page 
in mozilla, look at the gnome panel (which is on auto-hide), and then 
refesh the page again, I'll get page-ins.  (If I do it a second time, I 
don't)

What I'm basing this observation is
A) the computer feels slow
B) under memory pressure like running 'find', the cache grows really 
huge, and the number of 'active' pages gets too small.  MUCH smaller 
than reality.
C) the number of page-ins

  o Can I simply try something like "age = age>>1 + age>>2" to slow down 
aging?
  o does anybody else think that aging still needs tuning, or is it just me?

However, one benefit of the current MM is that large unused daemons get 
paged out completely, which was NOT true with the previous MMs.  Since I 
only have 64MB RAM and like to run daemons which I seldom use, I really 
appreciate this :)

2. operation is very slow when doing lots of I/O.

	Obviously, running 'find' will slow down a kernel compile since they are 
competing for bandwidth.  However, running 'find' also drastically slows 
down the interactivity of other programs, like netscape when they aren't 
doing I/O.  Do you know the main reason?

  a) the cache grows and pushes used processes out of memory?
  b) page aging is inaccurate, so all programs are stalled waiting for 
pageins?
  c) elevator problems?
  d) something else?

I'm voting on first b), the a).

3. zone problems
	I applied marcello's zoned.patch (the fixed version from his website) and 
operation is much improved.  The MM seems less likely to age everything 
down too far.

4.
Lastly, are there any better graphical interactive tools than xosview?
I like xosview, but I have a hard time seeing how it relates to 
/proc/meminfo.

thanks,

-BenRI
-- 
"I will begin again" - U2, 'New Year's Day'
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
