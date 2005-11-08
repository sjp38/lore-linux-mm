Date: Tue, 8 Nov 2005 14:44:42 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [RFC 2/2] Hugetlb COW
Message-ID: <20051108034442.GC14336@localhost.localdomain>
References: <1131397841.25133.90.camel@localhost.localdomain> <1131399533.25133.104.camel@localhost.localdomain> <1131400076.25133.110.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1131400076.25133.110.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, rohit.seth@intel.com, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 07, 2005 at 03:47:55PM -0600, Adam Litke wrote:
> On Mon, 2005-11-07 at 15:38 -0600, Adam Litke wrote:
> > [RFC] COW for hugepages
> > (Patch originally from David Gibson <dwg@au1.ibm.com>)
> > 
> > This patch implements copy-on-write for hugepages, hence allowing
> > MAP_PRIVATE mappings of hugetlbfs.
> > 
> > This is chiefly useful for cases where we want to use hugepages
> > "automatically" - that is to map hugepages without the knowledge of
> > the code in the final application (either via kernel hooks, or with
> > LD_PRELOAD).  We can use various heuristics to determine when
> > hugepages might be a good idea, but changing the semantics of
> > anonymous memory from MAP_PRIVATE to MAP_SHARED without the app's
> > knowledge is clearly wrong.
> 
> I forgot to mention in the original post that this patch is currently
> broken on ppc64 due to a problem with update_mmu_cache().  The proper
> fix is understood but backed up behind the powerpc merge activity.  

Now that the merge tree and 64k pages have been pulled into mainline I
updated this patch, and sent it off to paulus.  You'll fnid it under
the subject "ppc64: Make hash_preload() and update_mmu_cache() cope
with hugepages".

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
