Received: from ns.weiden.de (ns.weiden.de [193.203.186.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA09590
	for <linux-mm@kvack.org>; Tue, 3 Mar 1998 02:16:28 -0500
Date: Tue, 3 Mar 1998 08:16:08 +0100 (MET)
From: "Michael L. Galbraith" <mikeg@weiden.de>
Subject: Re: [PATCH] kswapd fix & logic improvement
In-Reply-To: <Pine.LNX.3.91.980303013255.7010A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980303073840.437A-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 1998, Rik van Riel wrote:

> Hi there,
> 
> here's the final patch to improve kswapd behaviour
> and improve the performance of the readahead code.
> 
> It was diffed against 2.1.89pre2, but since the VM
> code hasn't changed up to pre5, it can be applied
> easily.
> 
> I'm currently running a kernel with those changes,
> and it works better than before.
> 

Hello Rik,

I was able to stimulate a 'swap-attack' which took almost a hour to
recover control from.

Started X+KDE in 32bpp + some toys.  Started 5 instances of Xboard in
two machine mode.  This + toys took the machine up to a working set of
180+ MB on a 80 MB machine.  It was swapping like mad (better be) but 
all tasks were progressing nicely.  I let the xboards run until the
games were mostly over, and reset them to keep the pressure as high
as possible.

After about an hour and a half of this, I started a find on a drive
with 1.5G of 'stuff'.  The find ran nicely, but after it finished,
cpu usage dropped to almost zilch. The machine ended up doing almost
nothing but swapping and became useless and nearly unaccessable.

After (finally) managing to terminate a couple of processes and dropping
the working set to ~120MB, the xboards began to run again and cpu usage
snapped back to normal (pegged).

As I was composing this message (machine idle until updatedb started),
a slew of ..  'kswapd: failed, got xxx of 160' came flying across the
screen. Examining my logs, I find that there are about 10000 lines of
these messages beginning with ..

Mar  3 05:24:24 mikeg kernel: kswapd: failed, got 134 of 160
	(beginning of heavy swapping) and ending with
Mar  3 07:49:48 mikeg kernel: kswapd: failed, got 97 of 160

2.1.89pre5 + swap patch

	-Mike
