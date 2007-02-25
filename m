Date: Sat, 24 Feb 2007 16:53:11 -0800 (PST)
Message-Id: <20070224.165311.71091931.davem@davemloft.net>
Subject: Re: SLUB: The unqueued Slab allocator
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0702240931030.3912@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702232145340.1872@schroedinger.engr.sgi.com>
	<20070223.215439.92580943.davem@davemloft.net>
	<Pine.LNX.4.64.0702240931030.3912@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@engr.sgi.com>
Date: Sat, 24 Feb 2007 09:32:49 -0800 (PST)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@engr.sgi.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 23 Feb 2007, David Miller wrote:
> 
> > I also agree with Andi in that merging could mess up how object type
> > local lifetimes help reduce fragmentation in object pools.
> 
> If that is a problem for particular object pools then we may be able to 
> except those from the merging.

If it is a problem, it's going to be a problem "in general"
and not for specific SLAB caches.

I think this is really a very unwise idea.  We have enough
fragmentation problems as it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
