Received: from mail.ccr.net (ccr@alogconduit1an.ccr.net [208.130.159.14])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA29663
	for <linux-mm@kvack.org>; Fri, 20 Nov 1998 10:24:56 -0500
Subject: Re: Two naive questions and a suggestion
References: <Pine.LNX.3.96.981119210154.16706B-100000@mirkwood.dummy.home> <19981120012524.5136.qmail@sidney.remcomp.fr>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 20 Nov 1998 09:31:01 -0600
In-Reply-To: jfm2@club-internet.fr's message of "20 Nov 1998 01:25:24 -0000"
Message-ID: <m1sofegz4a.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr
Cc: H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "jfm2" == jfm2  <jfm2@club-internet.fr> writes:

jfm2> A (not to be published) conclusion is: "Kernel compiling is a thing
jfm2> performed only by idiots and kernel hackers".  I am not a kernel
jfm2> hacker and I have performed over 2 hundred of them.  :-)

No.

As far as functionality I don't trust a linux box that doesn't have
it's standard hardware drivers, comm port, floppy disk etc compiled
in.  A modular kernel seems to work well for protocol layers however.

An important advantage of linux is what you can do if something isn't
working automatically.

With Windows you have 2 possibilities.  
1) Either something works automatically
2) Soemthing doesn't work.

With Linux you have 3 posibilities.  
1) Something works automatically.  (We need more in this category).
2) Something with research and looking around can be made to work.
   (The ability to compile a kernel is an advantage here)
3) Something doesn't work.  (Linux has much less in this category than
                             any other OS)

With the memory management system.  There are tuning paramenters.
But generally resorting to them is dropping down to case 2.
And in most cases with 2.0 and probably also with 2.2 the memory
management system should be a case of it works automatically.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
