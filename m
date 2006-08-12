Message-ID: <33471.81.207.0.53.1155401489.squirrel@81.207.0.53>
In-Reply-To: <20060812141415.30842.78695.sendpatchset@lappy>
References: <20060812141415.30842.78695.sendpatchset@lappy>
Date: Sat, 12 Aug 2006 18:51:29 +0200 (CEST)
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
From: "Indan Zupancic" <indan@nul.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sat, August 12, 2006 16:14, Peter Zijlstra said:
> Hi,
>
> here the latest effort, it includes a whole new trivial allocator with a
> horrid name and an almost full rewrite of the deadlock prevention core.
> This version does not do anything per device and hence does not depend
> on the new netdev_alloc_skb() API.
>
> The reason to add a second allocator to the receive side is twofold:
> 1) it allows easy detection of the memory pressure / OOM situation;
> 2) it allows the receive path to be unbounded and go at full speed when
>    resources permit.
>
> The choice of using the global memalloc reserve as a mempool makes that
> the new allocator has to release pages as soon as possible; if we were
> to hoard pages in the allocator the memalloc reserve would not get
> replenished readily.

Version 2 had about 250 new lines of code, while v3 has close to 600, when
including the SROG code. And that while things should have become simpler.
So why use SROG instead of the old alloc_pages() based code? And why couldn't
you use a slightly modified SLOB instead of writing a new allocator?
It looks like overkill to me.

Greetings,

Indan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
