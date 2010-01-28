Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A85E36B008C
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 17:44:41 -0500 (EST)
Date: Thu, 28 Jan 2010 23:43:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25 of 31] transparent hugepage core
Message-ID: <20100128224345.GM1217@random.random>
References: <patchbomb.1264689194@v2.random>
 <ac9bbf9e2c95840eb237.1264689219@v2.random>
 <20100128175753.GF7139@csn.ul.ie>
 <20100128223653.GL1217@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128223653.GL1217@random.random>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 11:36:53PM +0100, Andrea Arcangeli wrote:
>  	do {								\
> -		if (unlikely(pmd_trans_huge(*(__pmd))))			\
> -			__split_huge_page_mm(__mm, __addr, __pmd);	\
> +		pmd_t ____pmd = __pmd;					\
> +		if (unlikely(pmd_trans_huge(*(____pmd))))		\
> +			__split_huge_page_mm(__mm, __addr, ____pmd);	\
>  	}  while (0)

then parenthesis should be moved from ____pmd to __pmd of course...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
