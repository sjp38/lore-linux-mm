Message-Id: <l03130314b708ed272d09@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0104221555090.1685-100000@imladris.rielhome.conectiva>
References: <l03130312b708cf8a37bf@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 22 Apr 2001 21:21:38 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>1) a minimal guaranteed working set for small processes, so root
>   can login and large hogs don't penalize good guys
>   (simpler than the working set idea, should work just as good)

This is also worth considering, perhaps as a subset of the working-set
algorithm.

I'm looking at sources, trying to figure out how to implement this kind of
thing...  but is there an easy way to find out what process(es) is/are
using a given page?  I'm talking about the page-replacement policy, of
course, where (current) is no help in this matter.

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
