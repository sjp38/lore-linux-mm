Message-Id: <l03130302b72ad6e553b5@[192.168.239.105]>
In-Reply-To: <200105180620.f4I6KNd05878@earth.backplane.com>
References: 
        <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva>
 <200105161754.f4GHsCd73025@earth.backplane.com>
 <3B04BA0D.8E0CAB90@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 18 May 2001 14:49:09 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: on load control / process swapping
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>, Terry Lambert <tlambert2@mindspring.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

>    The problem is not the resident set size, it's the
>    seeking that the program is causing as a matter of
>    course.

The RSS of 'ld' isn't the problem, no.  However, the working-set idea would
place an effective and sensible limit of the size of the disk cache, by
ensuring that other apps aren't being paged out beyond their non-working
sets.  Does this make sense?

FWIW, I've been running with a 2-line hack in my kernel for some weeks now,
which essentially forces the RSS of each process not to be forced below
some arbitrary "fair share" of the physical memory available.  It's not a
very clean hack, but it improves performance by a very large margin under a
thrashing load.  The only problem I'm seeing is a deadlock when I run out
of VM completely, but I think that's a separate issue that others are
already working on.

To others: is there already a means whereby we can (almost) calculate the
WS of a given process?  The "accessed" flag isn't a good one, but maybe the
'age' value is better.  However, I haven't quite clicked on how the 'age'
value is affected in either direction.

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
