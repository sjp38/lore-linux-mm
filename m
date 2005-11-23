Date: Tue, 22 Nov 2005 22:36:41 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
 conditions
In-Reply-To: <20051122213612.4adef5d0.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0511222231070.2084@graphe.net>
References: <20051122161000.A22430@unix-os.sc.intel.com>
 <20051122213612.4adef5d0.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Rohit Seth <rohit.seth@intel.com>, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Nov 2005, Andrew Morton wrote:

> > [PATCH]: This patch free pages (pcp->batch from each list at a time) from
> > local pcp lists when a higher order allocation request is not able to 
> > get serviced from global free_list.
> > 
> > This should help fix some of the earlier failures seen with order 1 allocations.
> > 
> > I will send separate patches for:
> > 
> > 1- Reducing the remote cpus pcp

That is already partially done by drain_remote_pages(). However, that 
draining is specific to this processors remote pagesets in remote 
zones.

> This significantly duplicates the existing drain_local_pages().

We need to extract __drain_pcp from all these functions and clearly 
document how they differ. Seth probably needs to call __drain_pages for 
each processor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
