Date: Tue, 30 Mar 2004 00:39:00 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040329223900.GK3808@dualathlon.random>
References: <20040325225919.GL20019@dualathlon.random> <Pine.GSO.4.58.0403252258170.4298@azure.engin.umich.edu> <20040326075343.GB12484@dualathlon.random> <Pine.LNX.4.58.0403261013480.672@ruby.engin.umich.edu> <20040326175842.GC9604@dualathlon.random> <Pine.GSO.4.58.0403271448120.28539@sapphire.engin.umich.edu> <20040329172248.GR3808@dualathlon.random> <Pine.GSO.4.58.0403291240040.14450@eecs2340u20.engin.umich.edu> <20040329180109.GW3808@dualathlon.random> <20040329124027.36335d93.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040329124027.36335d93.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2004 at 12:40:27PM -0800, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> >
> > There's now also a screwup in the writeback -mm changes for swapsuspend,
> > it bugs out in radix tree tag, I believe it's because it doesn't
> > insert the page in the radix tree before doing writeback I/O on it.
> 
> hmm, yes, we have pages which satisfy PageSwapCache(), but which are not
> actually in swapcache.

exactly.

> How about we use the normal pagecache APIs for this?

should work fine too and it exposes less internal vm details. I will
propose your fix for testing too.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
