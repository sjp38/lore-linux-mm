Date: Thu, 17 Jun 2004 08:10:31 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-ID: <20040617131031.GB8473@sgi.com>
References: <40D08225.6060900@colorfullife.com> <20040616180208.GD6069@sgi.com> <40D09872.4090107@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <40D09872.4090107@colorfullife.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-kernel@vger.kernel.org, lse-tech <lse-tech@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Manfred,

On Wed, Jun 16, 2004 at 08:58:58PM +0200, Manfred Spraul wrote:
> Could you try to reduce them? Something like (as root)
> 
> # cd /proc
> # cat slabinfo | gawk '{printf("echo \"%s %d %d %d\" > 
> /proc/slabinfo\n", $1,$9,4,2);}' | bash
> 
> If this doesn't help then perhaps the timer should run more frequently 
> and scan only a part of the list of slab caches.

I tried the modification you suggested and it had little effect.  On a 4 cpu
(otherwise idle) system I saw the characteristic 30+ usec interruptions
(holdoffs) every 2 seconds.

Since it's running in timer context, this of course includes all of the
timer_interrupt logic, but I've verified no other timers running during those
times (and I see only very short holdoffs during other timer interrupts).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
