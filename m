Received: (from uucp@localhost)
	by annwfn.erfurt.thur.de (8.9.3/8.9.2) with UUCP id WAA32524
	for linux-mm@kvack.org; Thu, 23 Sep 1999 22:59:57 +0200
Received: from nibiru.pauls.erfurt.thur.de (uucp@localhost)
	by pauls.erfurt.thur.de (8.9.3/8.9.3) with bsmtp id WAA01010
	for linux-mm@kvack.org; Thu, 23 Sep 1999 22:53:24 +0200
Message-ID: <37E98460.9731265@nibiru.pauls.erfurt.thur.de>
Date: Thu, 23 Sep 1999 01:37:36 +0000
From: Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de>
Reply-To: weigelt@nibiru.pauls.erfurt.thur.de
MIME-Version: 1.0
Subject: Dynamic Swap - How to do it ?
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi folks,

i've trying to develop a dynamic swap manager.

i've written a little deamon which frequently reads the memory
usage from /proc and adds swapfiles if necessary. but this doesn't
really satisfy me. so i'd like to do it at kernel level,
because there could be some critical situations:

what if an application (ore more) requests very much memory very fast - 
more than the swap deamon's min-space-range ? then the swap deamon
cant't increase the swapspace as fast as necessary and the application
doesn't get the memory - in the worst case the app doesnt care about it,
tries to access the (not allocated) memory and gets an SIGSEG.

so it would be better, if these applications are blocked until the swap
deamon has allocated the memory or definitively can't/won't allocate it.

but how should the kernel know which processes may be blocked and which 
not. and how to reserve memory for the swap deamon ?
there should be a flag in the process status field, which tells the
kernel
that this process won't be affected by this - because it _manages_ this.
(let's say an process type MEMORY_MANAGER or something like that)
and there has to be some code in the kernel, which tells the swap deamon
when it's time to increase the swap sapce.

what do you think about this ?

how could i do this ?

bye,
ew.



-------------------------------------------
lets go to another world ... oberon
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
