Received: from front2.grolier.fr (front2.grolier.fr [194.158.96.52])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA28719
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 15:51:48 -0500
Received: from sidney.remcomp.fr (ppp-163-157.villette.club-internet.fr [195.36.163.157])
	by front2.grolier.fr (8.9.0/MGC-980407-Frontal-No_Relay) with SMTP id VAA16294
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 21:51:29 +0100 (MET)
Date: 25 Nov 1998 20:29:27 -0000
Message-ID: <19981125202927.1916.qmail@sidney.remcomp.fr>
From: jfm2@club-internet.fr
In-reply-to: <m1af1fde1q.fsf@flinx.ccr.net> (ebiederm+eric@ccr.net)
Subject: Re: Two naive questions and a suggestion
References: <19981119002037.1785.qmail@sidney.remcomp.fr> 	<199811231808.SAA21383@dax.scot.redhat.com> 	<19981123215933.2401.qmail@sidney.remcomp.fr> <199811241117.LAA06562@dax.scot.redhat.com> <19981124214432.2922.qmail@sidney.remcomp.fr> <m1af1fde1q.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: ebiederm+eric@ccr.net
Cc: jfm2@club-internet.fr, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> >>>>> "jfm2" == jfm2  <jfm2@club-internet.fr> writes:
> 
> jfm2> Say the Web or database server can be deemed important enough for it
> jfm2> not being killed just because some dim witt is playing with the GIMP
> jfm2> at the console and the GIMP has allocated 80 Megs.
> 
> jfm2> More reallistically, it can happen that the X server is killed
> jfm2> (-9) due to the misbeahviour of a user program and you get
> jfm2> trapped with a useless console.  Very diificult to recover.  Specially
> jfm2> if you consider inetd could have been killed too, so no telnetting.
> 
> jfm2> You can also find half of your daemons, are gone.  That is no mail, no
> jfm2> printing, no nothing.
> 
> initd is never killed. Won't & can't be killed.
> initd should be configured to restart all of your important daemons if
> they go down.
> 

This does not solve the problem.  To begin with after an unclean
shutdown a database server spends time rolling back uncommitted
transactions and possibly writing somye comitted ones to the database
from its journals.  Users could prefer a database who doesn't go down
in the first place.

Second: the 80 Megs GIMP is still there so when init restarts the
database, the databse tries to allocate memory and it crashes again.

Third: A process can crash because it is misconfigured or a file is
corrupted.  And crash again if you restart it.  It si not Init's job
to do things like try five times and use a pager interface to send a
message to the admin in case there is a sixth crash.


It could be considered that "guaranteed" processes is not a good idea
but using Init is not the way to address the problem.

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
