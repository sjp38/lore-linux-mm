Message-Id: <l03130300b7025e809048@[192.168.239.105]>
In-Reply-To: <0japdtkjmd12nfj5nplvb4m7n8otq3f8po@4ax.com>
References: 
        <Pine.LNX.4.21.0104171650530.14442-100000@imladris.rielhome.conectiva>
 <l03130301b701fc801a61@[192.168.239.105]>
 <Pine.LNX.4.21.0104171650530.14442-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 17 Apr 2001 21:59:46 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>, Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

>>> I've got an even better idea.  Monitor each process's "working set" -
>>> ie. the set of unique pages it regularly "uses" or pages in over some
>>> period of (real) time.  In the event of thrashing, processes should be
>>> reserved an amount of physical RAM equal to their working set, except
>>> for processes which have "unreasonably large" working sets.
>>
>>This may be a nice idea to move the thrashing point out a bit
>>further, and as such may be nice in addition to the load control
>>code.
>
>Yes - in addition to, not instead of. Ultimately, there are workloads
>which CANNOT be handled without suspending/killing some tasks...

Umm.  Actually, my idea wasn't to move the thrashing point but to limit
thrashing to processes which (by some measure) deserve it.  Thus the
thrashing in itself becomes load control, rather than (as at present)
bringing the entire system down.  Hope that's a bit clearer?

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
