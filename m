Date: Mon, 14 Mar 2005 10:24:13 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: ia64 needs to shake memory from quicklists when there is memory pressure.
Message-ID: <20050314162412.GA9117@lnx-holt.americas.sgi.com>
References: <20050309170915.GA1583@lnx-holt.americas.sgi.com> <2120000.1110388509@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2120000.1110388509@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Robin Holt <holt@sgi.com>, akpm@osdl.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 09, 2005 at 09:15:10AM -0800, Martin J. Bligh wrote:
> > The "ideal" would be to have a node aware slab cache.  Since that
> > is probably a long time coming, 
> 
> Manfred already did one. Perhaps we can get that going again? would
> be useful for more than just this ...

Is this the kmem_cache_alloc_node() stuff?  If so, when I use that
for page table allocations, running AIM7 on a 32 processor machine
consistently live-locks the system.  Everybody is waiting inside
kmem_cache_alloc_node() cachep->spinlock.

Is there a different patch I should be looking for?

Thanks,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
