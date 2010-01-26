Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EF63C6B009E
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 12:49:25 -0500 (EST)
Message-ID: <4B5F2AFB.1080907@redhat.com>
Date: Tue, 26 Jan 2010 12:48:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 20 of 31] add pmd_huge_pte to mm_struct
References: <patchbomb.1264513915@v2.random> <1bd3154fd08b9710ca0e.1264513935@v2.random>
In-Reply-To: <1bd3154fd08b9710ca0e.1264513935@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 08:52 AM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
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
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
