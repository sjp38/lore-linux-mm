Message-Id: <l03130300b701154d843c@[192.168.239.105]>
In-Reply-To: <ehnmdtcljeb1bttp3r6o6o85b6agda0mdt@4ax.com>
References: <20010414022048.B10405@redhat.com>
 <m1wv8pti0o.fsf@frodo.biederman.org>
 <Pine.LNX.4.21.0104131317110.12164-100000@imladris.rielhome.conectiva>
 <20010414022048.B10405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 16 Apr 2001 22:40:31 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

>Ideally, I'd SIGSTOP each thrashing process. That way, enough
>processes can be swapped out and KEPT swapped out to allow others to
>complete their task, freeing up physical memory. Then you can SIGCONT
>the processes you suspended, and make progress that way. There are
>risks of "deadlocks", of course - suspend X, and all your graphical
>apps will lock up waiting for it. This should lower VM pressure enough
>to cause X to be restarted, though...

Strongly agree.  Two points that need defining for this:

- When does a process become "thrashing"?  Clearly paging-in in itself is
not a good measure, since all processes do this at startup - paging-in
which forces other memory out, OTOH, is a prime target.

- How long do we suspend it for?  Does this depend on how many times it's
been suspended recently?

A major point I've noticed is that a relatively small number of thrashing
processes can force small interactive applications out of physical memory,
too - this needs fixing urgently.

Example: running 3 active memory hogs on my 256Mb physical + 256Mb swap
machine causes XMMS to stutter and crackle; increasing the load to 4 memory
hogs causes it to stop working completely for extended periods of time.
The same effect can be seen on the (graphical) system monitors and on an
SSH session in progress from outside.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
