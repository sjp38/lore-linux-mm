Message-Id: <l03130303b71b795cab9b@[192.168.239.105]>
In-Reply-To: <Pine.A41.4.31.0105062307290.59664-100000@pandora.inf.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 6 May 2001 22:59:19 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: page_launder() bug
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BERECZ Szabolcs <szabi@inf.elte.hu>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>-			 page_count(page) == (1 + !!page->buffers));

Two inversions in a row?  I'd like to see that made more explicit,
otherwise it looks like a bug to me.  Of course, if it IS a bug...

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
