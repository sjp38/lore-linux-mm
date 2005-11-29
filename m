Date: Tue, 29 Nov 2005 10:49:35 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 1/3] mm: NUMA slab -- add alien cache drain statistics
Message-ID: <20051129184934.GA3697@localhost.localdomain>
References: <20051129085049.GA3573@localhost.localdomain> <Pine.LNX.4.62.0511290954010.14722@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0511290954010.14722@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, manfred@colorfullife.com, Alok Kataria <alokk@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 29, 2005 at 09:57:58AM -0800, Christoph Lameter wrote:
> On Tue, 29 Nov 2005, Ravikiran G Thirumalai wrote:
> 
> > 
> > This will be useful when we can dynamically tune the alien cache limit.  
> > Currently, the alien cache limit is fixed at 12.
> 
> It may be best to first enable the basic manual tuning. See 
> slabinfo_write.

We already have a patch for that on our local tree.  Will send it out soon 
after some more tests

> 
> How would you propose to determine the length?
>

All kmem caches won't experience remote frees. Depending on the work-load,
some caches might experience frequent remote frees. This statistic helps us
determine which cache is experiencing heavy remote free activity, and the
sysadmin may tune the alien cache limit dynamically (just like the array
cache limit) by writing to /proc/slabinfo.  There cannot be one value good
enough for everyone so this should be a tunable.

Thanks,
Kiran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
