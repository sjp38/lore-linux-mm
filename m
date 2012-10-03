Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 5EA0F6B0074
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 17:25:21 -0400 (EDT)
Date: Wed, 3 Oct 2012 14:25:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] mm, thp: fix mlock statistics fix
Message-Id: <20121003142519.93375e01.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1210031403270.4352@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
	<alpine.LSU.2.00.1209192021270.28543@eggly.anvils>
	<alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
	<alpine.LSU.2.00.1209271814340.2107@eggly.anvils>
	<20121003131012.f88b0d66.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1210031403270.4352@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 3 Oct 2012 14:10:41 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> > The free_page_mlock() hunk gets dropped because free_page_mlock() is
> > removed.  And clear_page_mlock() doesn't need this treatment.  But
> > please check my handiwork.
> > 
> 
> I reviewed what was merged into -mm and clear_page_mlock() does need this 
> fix as well.

argh, it got me *again*.  grr.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm: document PageHuge somewhat

Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/hugetlb.c |    5 +++++
 1 file changed, 5 insertions(+)

diff -puN mm/hugetlb.c~mm-document-pagehuge-somewhat mm/hugetlb.c
--- a/mm/hugetlb.c~mm-document-pagehuge-somewhat
+++ a/mm/hugetlb.c
@@ -671,6 +671,11 @@ static void prep_compound_gigantic_page(
 	}
 }
 
+/*
+ * PageHuge() only returns true for hugetlbfs pages, but not for normal or
+ * transparent huge pages.  See the PageTransHuge() documentation for more
+ * details.
+ */
 int PageHuge(struct page *page)
 {
 	compound_page_dtor *dtor;
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
