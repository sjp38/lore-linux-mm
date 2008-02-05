Date: Mon, 4 Feb 2008 17:15:05 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [git pull] SLUB updates for 2.6.25
In-Reply-To: <200802051142.20413.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0802041700170.5438@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802041206190.3241@schroedinger.engr.sgi.com>
 <200802051105.12194.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0802041629290.5057@schroedinger.engr.sgi.com>
 <200802051142.20413.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Nick Piggin wrote:

> Anyway, not saying the operations are useless, but they should be
> made available to core kernel and implemented per-arch. (if they are
> found to be useful)

The problem is to establish the usefulness. These measures may bring 1-2% 
in a pretty unstable operation mode assuming that the system is doing 
repetitive work. The micro optimizations seem to be often drowned out 
by small other changes to the system.

There is the danger that a gain is seen that is not due to the patch but 
due to other changes coming about because code is moved since patches 
change execution paths.

Plus they may be only possible on a specific architecture. I know that our 
IA64 hardware has special measures ensuring certain behavior of atomic ops 
etc, I guess Intel has similar tricks up their sleeve. At 8p there are 
likely increasing problems with lock starvation where your ticketlock 
helps. That is why I thought we better defer the stuff until there is some 
more evidence that these are useful.

I got particularly nervous about these changes after I saw small 
performance drops due to the __unlock patch on the dual quad. That should 
have been a consistent gain.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
