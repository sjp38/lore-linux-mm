Received: from front3.grolier.fr (front3.grolier.fr [194.158.96.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA02107
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 21:08:54 -0500
Received: from sidney.remcomp.fr (ppp-107-225.villette.club-internet.fr [194.158.107.225])
	by front3.grolier.fr (8.9.0/MGC-980407-Frontal-No_Relay) with SMTP id WAA18229
	for <linux-mm@kvack.org>; Fri, 27 Nov 1998 22:18:02 +0100 (MET)
Date: 27 Nov 1998 21:14:17 -0000
Message-ID: <19981127211417.1877.qmail@sidney.remcomp.fr>
From: jfm2@club-internet.fr
In-reply-to: <199811271745.RAA01484@dax.scot.redhat.com> (sct@redhat.com)
Subject: Re: Two naive questions and a suggestion
References: <Pine.LNX.3.96.981126080204.24048J-100000@mirkwood.dummy.home>
	<19981126195942.1431.qmail@sidney.remcomp.fr> <199811271745.RAA01484@dax.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
To: sct@redhat.com
Cc: jfm2@club-internet.fr, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Date: Fri, 27 Nov 1998 17:45:55 GMT
> From: "Stephen C. Tweedie" <sct@redhat.com>
> Content-Type: text/plain; charset=us-ascii
> Cc: H.H.vanRiel@phys.uu.nl, sct@redhat.com, linux-mm@kvack.org
> X-UIDL: 62f6721511a1878f885583dcf30990c3
> 
> Hi,
> 
> On 26 Nov 1998 19:59:42 -0000, jfm2@club-internet.fr said:
> 
> > My idea was:
> 
> > -VM exhausted and process allocating is a normal process then kill
> >  process.
> >  -VM exhausted and process is a guaranteed one then kill a non
> >  guaranteed process.
> > -VM exhausted, process is guaranteed but only remaining processes are
> >  guaranteed ones.  Kill allocated process.
> 
> But the _whole_ problem is that we do not necessarily go around
> killing processes.  We just fail requests for new allocations.  In
> that case we still have not run out of memory yet, but a daemon may
> have died.  It is simply not possible to guarantee all of the future
> memory allocations which a process might make!
> 

The word "guaranteed" was an unfortunate one.  "Protected" would have
been better.

As a user I feel there are processes more equal than others and I find
unfortunate one of them is killed when it tries to grow its stack
(SIGKILL so no recovering) and it is unable to do so due to
mibehaviour of an unimportant process.  I think they should be
protected and that it is the sysadmin and not a heuristic who should
define what is important and what is not in a box.  We cannot
guarantee the success of a memory allocation but we can make mission
critical software motre robust.

But if you think the idea is bad we can kill this thread.

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
