Received: from front3.grolier.fr (front3.grolier.fr [194.158.96.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA16652
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 18:55:30 -0500
Received: from sidney.remcomp.fr (ppp-101-25.villette.club-internet.fr [194.158.101.25])
	by front3.grolier.fr (8.9.0/MGC-980407-Frontal-No_Relay) with SMTP id AAA24947
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 00:55:25 +0100 (MET)
Date: 23 Nov 1998 21:59:33 -0000
Message-ID: <19981123215933.2401.qmail@sidney.remcomp.fr>
From: jfm2@club-internet.fr
In-reply-to: <199811231808.SAA21383@dax.scot.redhat.com> (sct@redhat.com)
Subject: Re: Two naive questions and a suggestion
References: <19981119002037.1785.qmail@sidney.remcomp.fr> <199811231808.SAA21383@dax.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
To: sct@redhat.com
Cc: jfm2@club-internet.fr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> 
> Hi,
> 
> On 19 Nov 1998 00:20:37 -0000, jfm2@club-internet.fr said:
> 
> > 1) Is there any text describing memory management in 2.1?  (Forgive me
> >    if I missed an obvious URL)
> 
> The source code. :)
> 

I knew about it.  :)  And this is not an URL :)

> > 2) Are there plans for implementing the swapping of whole processes a
> >    la BSD?
> 
> Not exactly, but there are substantial plans for other related changes.
> In particular, most of the benefits of BSD-style swapping can be
> achieved through swapping of page tables, dynamic RSS limits and
> streaming swapout, all of which are on the slate for 2.3.
> 

The problem is: will you be able to manage the following situation?

Two processes running in an 8 Meg box.  Both will page fault every ms
if you give them 4 Megs (they are scanning large arrays so no
locality), a page fault will take 20 ms to handle.  That means only 5%
of the CPU time is used, remainder is spent waiting for page being
brought from disk or pushing a page of the other process out of
memory.  And both of these processes would run like hell (no page
fault) given 6 Megs of memory.

Only solution I see is stop one of them (short of adding memory :) and
let the other one make some progress.  That is swapping.  Of course
swapping can be undesiarable in work stations and that is the reason I
suggested user control about MM policy be it by recompiling, by /proc
or by module insertion.

In 96 I asked for that same feature, gave the same example (same
numbers :-) and Alan Cox agreed but told Linux was not used under
heavy loads. That means we are in a catch 22 situation: Linux not used
for heavy loads because it does not handle them well and the necessary
feaatures not implemented because it is not used in such situations.


And now we are at it: in 2.0 I found a deamon can be killed by the
system if it runs out of VM.  Problem is: it was a normal user process
who had allocatedc most of it and in addition that daemon could be
important enough it is better to kill anything else, so it would be
useful to give some privilege to root processes here.

I think this ends my Christmas wish list.  :)

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
