Received: from front2.grolier.fr (front2.grolier.fr [194.158.96.52])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA27474
	for <linux-mm@kvack.org>; Fri, 20 Nov 1998 01:47:53 -0500
Received: from sidney.remcomp.fr (ppp-99-95.villette.club-internet.fr [194.158.99.95])
	by front2.grolier.fr (8.9.0/MGC-980407-Frontal-No_Relay) with SMTP id HAA21241
	for <linux-mm@kvack.org>; Fri, 20 Nov 1998 07:45:56 +0100 (MET)
Date: 20 Nov 1998 01:25:24 -0000
Message-ID: <19981120012524.5136.qmail@sidney.remcomp.fr>
From: jfm2@club-internet.fr
In-reply-to: <Pine.LNX.3.96.981119210154.16706B-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Thu, 19 Nov 1998 21:05:35 +0100 (CET))
Subject: Re: Two naive questions and a suggestion
References: <Pine.LNX.3.96.981119210154.16706B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@phys.uu.nl
Cc: jfm2@club-internet.fr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On 19 Nov 1998 jfm2@club-internet.fr wrote:
> 
> > 1) Is there any text describing memory management in 2.1?  (Forgive me
> >    if I missed an obvious URL)
> 
> Not yet, I really should be working on that (the code
> seems to have stabilized now)...
> 
> > 2) Are there plans for implementing the swapping of whole processes a
> >    la BSD?
> 
> Yes, there are plans. The plans are quite detailed too, but
> I think I haven't put them up on my home page yet.
> 

This will close the gap between Linux and *BSDs at high loads.  It
will also close the mouthes of some BSD people who talk loudly about
what areas where BSD is superior and carefully forget SMP, Elf or
modules to name just a few areas where Linux got it first.

> > Suggestion: Given that the requiremnts for a workstation (quick
> > response) are different than for a server (high throughput) it could
> > make sense to allow the user either use /proc for selecting the VM
> > policy or have a form of loadable VM manager.  Or select it at
> > compile time. 
> 
> There are quite a lot of things you can tune in /proc,
> I don't know if you have read the documentation, but
> if you start trying things you'll be amazed hom much
> you can change the system's behaviour with the existing
> controls.
> 

I have read a bit about them but sometimes changing the algorythm is
the right thing to do.

> Btw, since you are so enthusiastic about documentation,
> would you be willing to help me write it?
> 

I could try to help you but it will be limited help.  I already work
on a project of "Linux for normal people" and I also wanted to write
an article about optimizing a Linux box.  The goal is to smash the
myth about kernel compiling.  Why?  Because in 95 my brother in law
needed a computer for his thesis in Spanish litterature.  I remebered
kernel compiling and I led him to Apple Expo.  That day one thing was
clear: Linux will never reach world domination as long as litterature
professors cannot use it and as long as kernel compiling be necessary
or even recommended then Linux will be off limits for litterature
professors.

So I scanned the source code in 2.0.34 and found the unsignificant
differences between code compiled for Pentiums and 386.  Then I
compiled the Byte benchmark using the same compile flags used for the
386 kernels and the ones for Pentiums and PPros.  Difference in speed
was < 2 % both on a real Pentium and on a K6.  So much for "it will
allow you to tune to the processor".

About memory savings.  First of all in 98 distributors shipping
crippled kernels should be shot: modular 2.0 has been around for over
two years.  Also modularity has reduced the memory savings you get
from recompiling the kernel (if the distributor did a good job) qwhile
machines got bigger: over 1.5 Megs saved on an 8 Meg box are
significant (1.2.13 in 95), 500K on a 32 Meg box are a triffle (2.0 in
98).  This is not entirely true: you can write pathological programs
where a single page means the difference between blinding speed and
hours swapping.  Also the significant number is the increase in memory
you lack: a 500K deficit becoming 1 Meg.  Consider also disk
bandwidth: being 16 megs short on a 32 Megs is much worse than 4 Meg
box on a 8 Meg because you need much more time to push 16 Megs to the
disk.  On the other hand proceses will have to spend more time
analyzing a big array on a big box than a small one in a small box
(processor speed being equal) and this plays in the side of the 32
Megs being 16 Megs short for normal, non pathological programs.
Finally there is the question of probability: 500K is under 2% on a 32
Meg box so there is a good chance that when programs need more memory
than what you have they miss the mark by 20 or 30% and rarely fall
just straight on the 500K zone.

Needs refining but indulge with the fact I am writing at 2am.

A (not to be published) conclusion is: "Kernel compiling is a thing
performed only by idiots and kernel hackers".  I am not a kernel
hacker and I have performed over 2 hundred of them.  :-)

Perhaps we could help one another for our docs/articles.

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
