Message-Id: <l03130322b6e3ced39e99@[192.168.239.101]>
In-Reply-To: <3ABE132F.E919F908@evision-ventures.com>
References: <3ABDF8A6.7580BD7D@evision-ventures.com>
 <l03130321b6e3c0533688@[192.168.239.101]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 25 Mar 2001 17:36:21 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] OOM handling
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Dalecki <dalecki@evision-ventures.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "James A. Sutherland" <jas88@cam.ac.uk>, Guest section DW <dwguest@win.tue.nl>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> I didn't quite understand Martin's comments about "not normalised" -
>> presumably this is some mathematical argument, but what does this actually
>> mean?
>
>Not mathematics. It's from physics. Very trivial physics, basic scool
>indeed.
>If you try to calculate some weightning
>factors which involve different units (in this case mostly seconds and
>bits)
>then you will have to make sure tha those units get factorized out.
>Rik is just throwing the absolute values together...

Understood - my Physics courses covered this as well, but not using the
word "normalise".

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
