Date: Tue, 29 Nov 2005 09:57:58 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch 1/3] mm: NUMA slab -- add alien cache drain statistics 
In-Reply-To: <20051129085049.GA3573@localhost.localdomain>
Message-ID: <Pine.LNX.4.62.0511290954010.14722@schroedinger.engr.sgi.com>
References: <20051129085049.GA3573@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, manfred@colorfullife.com, Alok Kataria <alokk@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Nov 2005, Ravikiran G Thirumalai wrote:

> NUMA slab allocator frees remote objects to a local alien cache.
> But if the local alien cache is full, the alien cache
> is drained directly to the remote node.
> 
> This patch adds a statistics counter which is incremented everytime the 
> local alien cache is full and we have to drain it to the remote nodes list3.
> 
> This will be useful when we can dynamically tune the alien cache limit.  
> Currently, the alien cache limit is fixed at 12.

It may be best to first enable the basic manual tuning. See 
slabinfo_write.

How would you propose to determine the length?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
