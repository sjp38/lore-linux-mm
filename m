Received: from mail.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA26879
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 09:30:20 -0500
Subject: Re: Two naive questions and a suggestion
References: <19981119002037.1785.qmail@sidney.remcomp.fr> 	<199811231808.SAA21383@dax.scot.redhat.com> 	<19981123215933.2401.qmail@sidney.remcomp.fr> <199811241117.LAA06562@dax.scot.redhat.com> <19981124214432.2922.qmail@sidney.remcomp.fr>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 25 Nov 1998 08:48:01 -0600
In-Reply-To: jfm2@club-internet.fr's message of "24 Nov 1998 21:44:32 -0000"
Message-ID: <m1af1fde1q.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr
Cc: sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "jfm2" == jfm2  <jfm2@club-internet.fr> writes:

jfm2> Say the Web or database server can be deemed important enough for it
jfm2> not being killed just because some dim witt is playing with the GIMP
jfm2> at the console and the GIMP has allocated 80 Megs.

jfm2> More reallistically, it can happen that the X server is killed
jfm2> (-9) due to the misbeahviour of a user program and you get
jfm2> trapped with a useless console.  Very diificult to recover.  Specially
jfm2> if you consider inetd could have been killed too, so no telnetting.

jfm2> You can also find half of your daemons, are gone.  That is no mail, no
jfm2> printing, no nothing.

initd is never killed. Won't & can't be killed.
initd should be configured to restart all of your important daemons if
they go down.

Currently most unix systems ( I don't think i'ts linux specific) are
misconfigured so they don't automatically restart their important
daemons if they go down.

jfm2> In situation like those above I would like Linux supported a concept
jfm2> like guaranteed processses: if VM is exhausted by one of them then try
jfm2> to get memory by killing non guaranteed processes and only kill the
jfm2> original one if all reamining survivors are guaranteed ones.
jfm2> It would be better for mission critical tasks.

Some.  But it would be simple and much healthier for tasks that can be
down for a little bit to have initd restart the processes after they
go down.   That allows for other cases when the important system
daemons goes down, is more robust, and doesn't require kernel changes.


Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
