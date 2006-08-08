Subject: Re: [RFC][PATCH 4/9] e100 driver conversion
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <44D8F074.8060001@intel.com>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	 <20060808193405.1396.14701.sendpatchset@lappy> <44D8F074.8060001@intel.com>
Content-Type: text/plain
Date: Tue, 08 Aug 2006 22:18:03 +0200
Message-Id: <1155068284.23134.23.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Auke Kok <auke-jan.h.kok@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-08-08 at 13:13 -0700, Auke Kok wrote:
> Peter Zijlstra wrote:
> > Update the driver to make use of the netdev_alloc_skb() API and the
> > NETIF_F_MEMALLOC feature.
> 
> this should be done in two separate patches. I should take care of the netdev_alloc_skb()
> part too for e100 (which I've already queued internally), also since ixgb still needs it.
> 
> do you have any plans to visit ixgb for this change too?

Well, all drivers are queued, these were just the ones I have hardware
for in running systems (except wireless).

Since this patch-set is essentially a RFC, your patch will likely hit
mainline ere this one, at that point I'll rebase.

For future patches I'll split up in two if people are so inclined.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
