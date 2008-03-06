Date: Wed, 5 Mar 2008 16:39:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] 2.6.25-rc3-mm1 - Mempolicy:  make
 dequeue_huge_page_vma() obey MPOL_BIND nodemask
Message-Id: <20080305163950.82cb9c4b.akpm@linux-foundation.org>
In-Reply-To: <1204733195.5026.20.camel@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	<20080227214734.6858.9968.sendpatchset@localhost>
	<20080228133247.6a7b626f.akpm@linux-foundation.org>
	<20080229145030.GD6045@csn.ul.ie>
	<1204300094.5311.50.camel@localhost>
	<20080304180145.GB9051@csn.ul.ie>
	<1204733195.5026.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: mel@csn.ul.ie, nacc@us.ibm.com, agl@us.ibm.com, wli@holomorphy.com, clameter@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 05 Mar 2008 11:06:34 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Subject: [PATCH] 2.6.25-rc3-mm1 - Mempolicy:  make dequeue_huge_page_vma() obey MPOL_BIND nodemask

whine.

a) Please put the "2.6.25-rc3-mm1" stuff inside [].  This tells the
   receiver that this is not-to-be-included metadata pertaining only to
   this email.

b) Sometimes (quite often) people send me patches advertised as being
   for "2.6.x-mm-y" whereas they actually fix problems which are in
   mainline (or even -stable).

   So I tend to not believe it when people say that.

> Date: Wed, 05 Mar 2008 11:06:34 -0500
> Organization: HP/OSLO
> X-Mailer: Evolution 2.6.1 
> 
> PATCH Mempolicy - make dequeue_huge_page_vma() obey MPOL_BIND nodemask
> 
> dequeue_huge_page_vma() is not obeying the MPOL_BIND nodemask
> with the zonelist rework.  It needs to search only zones in 
> the mempolicy nodemask for hugepages.
> 
> Use for_each_zone_zonelist_nodemask() instead of
> for_each_zone_zonelist().
> 
> Note:  this will bloat mm/hugetlb.o a bit until Mel reworks the
> inlining of the for_each_zone... macros and helpers.
> 
> Added mempolicy helper function mpol_bind_nodemask() to hide
> the details of mempolicy from hugetlb and to avoid
> #ifdef CONFIG_NUMA in dequeue_huge_page_vma().
> 

But this patch does indeed fix an only-in-mm problem.  afacit it is a
bugfix against mm-filter-based-on-a-nodemask-as-well-as-a-gfp_mask.patch. 
At least, that's how I've staged it.

If you have already worked that information out, please let me know.

> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

You're "Lee", not " Lee" ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
