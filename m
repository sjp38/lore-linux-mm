Message-Id: <l0313032db6e56b7c852b@[192.168.239.101]>
In-Reply-To: <vba4rwgtdso.fsf@mozart.stat.wisc.edu>
References: Jonathan Morton's message of "Sun, 25 Mar 2001 17:36:21 +0100"
 <3ABDF8A6.7580BD7D@evision-ventures.com>
 <l03130321b6e3c0533688@[192.168.239.101]>
 <l03130322b6e3ced39e99@[192.168.239.101]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 26 Mar 2001 23:00:42 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] OOM handling
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kevin Buhr <buhr@stat.wisc.edu>
Cc: Martin Dalecki <dalecki@evision-ventures.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> Understood - my Physics courses covered this as well, but not using the
>> word "normalise".
>
>Be that as it may, Martin's comments about normalizing are nonsense.
>Rik's killer (at least in 2.4.3-pre7) produces a badness value that's
>a product of badness factors of various units.  It then uses these
>products only for relative comparisons, choosing the process with
>maximum badness product to kill.  No normalization is necessary, nor
>would it have any effect.
>
>The reason a 256 Meg process on a 1 Gig machine was being killed had
>nothing to do with normalization---it was a bug where the OOM killer
>was being called long before we were reduced to last resorts.

Of course, I realised that.  Actually, what the code does is take an
initial badness factor (the memory usage), then divide it using goodness
factors (some based on time, some purely arbitrary), both of which can be
considered dimensionless.  Also, at the end, the absolute value is not
considered - we simply look at the biggest one and kill it.  All
"denormalisation" does is scale all the values, it doesn't affect which one
actually turns out biggest.


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
