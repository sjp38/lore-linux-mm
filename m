Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 20B726B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:13:59 -0500 (EST)
Date: Thu, 18 Nov 2010 13:13:40 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 23 of 66] add pmd_huge_pte to mm_struct
Message-ID: <20101118131340.GQ8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <8497eaf69975ceba0c79.1288798078@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <8497eaf69975ceba0c79.1288798078@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:27:58PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This increase the size of the mm struct a bit but it is needed to preallocate
> one pte for each hugepage so that split_huge_page will not require a fail path.
> Guarantee of success is a fundamental property of split_huge_page to avoid
> decrasing swapping reliability and to avoid adding -ENOMEM fail paths that
> would otherwise force the hugepage-unaware VM code to learn rolling back in the
> middle of its pte mangling operations (if something we need it to learn
> handling pmd_trans_huge natively rather being capable of rollback). When
> split_huge_page runs a pte is needed to succeed the split, to map the newly
> splitted regular pages with a regular pte.  This way all existing VM code
> remains backwards compatible by just adding a split_huge_page* one liner. The
> memory waste of those preallocated ptes is negligible and so it is worth it.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
