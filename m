From: Andi Kleen <ak@suse.de>
Subject: Re: FW: [PATCH 0/3] Demand faulting for huge pages
Date: Mon, 10 Oct 2005 11:32:04 +0200
References: <200510100651.j9A6pZg13871@unix-os.sc.intel.com>
In-Reply-To: <200510100651.j9A6pZg13871@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510101132.05620.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, "Seth, Rohit" <rohit.seth@intel.com>, William Irwin <wli@holomorphy.com>, agl@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Monday 10 October 2005 08:51, Chen, Kenneth W wrote:

> Demand paging is one aspect of enhancing generality of hugetlb.  Intel
> initially proposed the feature 18 month ago [* see link below] along
> with SGI. Christoph Lameter at SGI scratched that subject Oct 2004.
> And now, Adam at IBM attempts it again.  There is a growing need to
> make hugetlb easier to use, more transparency in using hugetlb pages
> etc.  All requires hugetlb code to be more generalized, instead of
> reducing functionality.

It's also badly needed to make hugetlbfs NUMA policy aware. mbind
requires allocation on demand, because it runs after mmap and
cannot fix up the policy when the pages are already allocated.

> Granted, the patch I posted on expanding ftruncate will be replaced
> once demand paging goes in.  I wanted to demonstrate that it is a
> feature we should implement, instead of cutting back more on current
> thin functionality in hugetlbfs. (with demand paging, expanding
> ftruncate should be really easy and clean, instead of "peculiar
> semantics" all because of prefaulting).

I would like to have it. I remember hating to implement extending 
truncate by hand when I did the test programs for the hugetlbfs numa policy.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
