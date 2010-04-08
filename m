Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0408B6B020A
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 19:18:25 -0400 (EDT)
Date: Fri, 9 Apr 2010 01:17:05 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
Message-ID: <20100408231705.GM5749@random.random>
References: <patchbomb.1270691443@v2.random>
 <4BBDA43F.5030309@redhat.com>
 <4BBDC181.5040205@redhat.com>
 <20100408152302.GA5749@random.random>
 <alpine.DEB.2.00.1004081030440.6321@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004081030440.6321@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Avi Kivity <avi@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This may have been caused by the same anon-vma bug that is being
debugged for mainline as it'd free anon-vma too early leading to
memory corruption. split_huge_page is a super heavy user of anon-vmas,
so that would explain all the issues, and also another crash I had in
split_huge_page where the rmap chain found a number of pmd mapping the
hugepage different than page_mapcount. For swap that means mlock, for
split_huge_page not being able to update some huge pmd is fatal so
there's plenty of BUG_ON to check all goes well and there's no risk of
corruption later on.

We need to test with Linus's fix for anon-vma bug, and I guess
everything will go fine when that bug is solved.

I added more commentary as well to cover an ordering issue in the
anon_vma_prepare.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
