Received: from front7.grolier.fr (front7.grolier.fr [194.158.96.57])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA28705
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 15:51:41 -0500
Received: from sidney.remcomp.fr (ppp-163-157.villette.club-internet.fr [195.36.163.157])
	by front7.grolier.fr (8.9.0/MGC-980407-Frontal-No_Relay) with SMTP id VAA06780
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 21:51:59 +0100 (MET)
Date: 25 Nov 1998 20:01:40 -0000
Message-ID: <19981125200140.1226.qmail@sidney.remcomp.fr>
From: jfm2@club-internet.fr
In-reply-to: <Pine.LNX.3.96.981125073253.30767B-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Wed, 25 Nov 1998 07:41:41 +0100 (CET))
Subject: Re: Two naive questions and a suggestion
References: <Pine.LNX.3.96.981125073253.30767B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@phys.uu.nl
Cc: jfm2@club-internet.fr, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Without swapin readahead, we'll be unable to implement them
> properly however :(
> 
> > > > And now we are at it: in 2.0 I found a deamon can be killed by the
> > > > system if it runs out of VM.  
> > > 
> > > Same on any BSD.
> > 
> > Say the Web or database server can be deemed important enough for it
> > not being killed just because some dim witt is playing with the GIMP
> > at the console and the GIMP has allocated 80 Megs.
> 
> I sounds remarkably like you want my Out Of Memory killer
> patch. This patch tries to remove the randomness in killing
> a process when you're OOM by carefully selecting a process
> based on a lot of different factors (size, age, CPU used,
> suid, root, IOPL, etc).
> 
> It needs to be cleaned up, ported to 2.1.129 and improved
> a little bit though... After that it should be ready for
> inclusion in the kernel.
> 

Your scheme is (IMHO) far too complicated and (IMHO) falls short.  The
problem is that the kernel has no way to know what is the really
important process in the box.  For instance you can have a database
server running as normal user and that be considered far more
important the X server (setuid root) whose only real goal is to allow
a user friendly UI for administering the database.

Why not simply allow a root-owned process declare itself (and the
program it will exec into) as "guaranteed"?  Only a human can know
what is important and what is unimportant in a box so it should be a
human who, by the way of starting a program throuh a "guaranteer", has
the final word on what should be protected

Allow an option for having this priviliege extended to descendents of
the process given some database programs start special daemons for
other tasks and will not run without them.  Or a box used as a mail
server using qmail: qmail starts sub-servers each one for a different
task.

Of course this is only a suugestion for a mechanism but the important
is allowing a human to have the final word.

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
