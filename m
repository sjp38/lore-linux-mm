Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA27093
	for <linux-mm@kvack.org>; Thu, 27 Nov 1997 09:25:47 -0500
Date: Thu, 27 Nov 1997 14:35:31 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: fork: out of memory
In-Reply-To: <Pine.OSF.3.95.971127130913.4485D-100000@ruunat.fys.ruu.nl>
Message-ID: <Pine.LNX.3.91.971127143242.746A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: John Alvord <jalvo@cloud9.net>, Jan Echternach <jec@DInet.de>, Mike Jagdis <mike@roan.co.uk>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 27 Nov 1997, Rik van Riel wrote:

> > Memory is getting so inexpensive in some environments, wouldn't it make
> > sense to have an option to reserve DMA-able memory at init time? With 16
> > megs going for $60, it is worth setting aside 4megs or 8 megs which would
> > have to be specially requested.
> 
> 128 k would be enough, the largest DMA buffer allocated by devices
> is 64k in size (soundcard) and ftape uses 3 32k area's. the scsi

On second thought, it doesn't need to be completely free... If
we can also use it for cache/buffer memory... Kicking that out
when we can't find a 64kB area for DMA memory might be bad for
performance (temporarily), but since it is good for stability,
it is a Good Thing (any system outperforms a crashed system :)

in search of a Better Thing (tm),

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
