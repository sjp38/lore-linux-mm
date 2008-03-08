Date: Sat, 8 Mar 2008 12:41:22 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [6/13] Core maskable allocator
Message-ID: <20080308114122.GA27074@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307090716.9D3E91B419C@basil.firstfloor.org> <20080308140334.15987554.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080308140334.15987554.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > +early_param("maskzone", setup_maskzone);
> 
> please confirm mask_zone_size is aligned to MAX_ORDER.

It's not. Since the buddy allocator is not used MAX_ORDER doesn't really
exist for the mask allocator. It can handle arbitary size allocations.

Also strictly seen the maskzone is part of the lowmem zone.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
