Message-Id: <l03130321b6e3c0533688@[192.168.239.101]>
In-Reply-To: 
        <Pine.LNX.4.21.0103251156450.1863-100000@imladris.rielhome.conectiva>
References: <3ABDF8A6.7580BD7D@evision-ventures.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 25 Mar 2001 16:44:57 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] OOM handling
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Martin Dalecki <dalecki@evision-ventures.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "James A. Sutherland" <jas88@cam.ac.uk>, Guest section DW <dwguest@win.tue.nl>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>- the AGE_FACTOR calculation will overflow after the system has
>  an uptime of just _3_ days

Tsk tsk tsk...

>Now if you can make something which preserves the heuristics which
>serve us so well on desktop boxes and add something that makes it
>also work on your Oracle servers, then I'd be interested.

What do people think of my "adjustments" to the existing algorithm?  Mostly
it gives extra longevity to low-UID and long-running processes, which to my
mind makes sense for both server and desktop boxen.

Taking for example an 80Mb process under my adjustments, it is reduced to
under the badness of a new shell process after less than a week's uptime
(compared to several months), especially if it is run as low-UID.  Small,
short-lived interactive processes still don't get *too* adversely affected,
but a memory hog with only a few hours' uptime will still get killed with
high probability (pretty much what we want).

I didn't quite understand Martin's comments about "not normalised" -
presumably this is some mathematical argument, but what does this actually
mean?

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
