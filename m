Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6E7A16B0034
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 09:51:36 -0400 (EDT)
Date: Tue, 10 Sep 2013 14:51:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/9] migrate: make core migration code aware of hugepage
Message-ID: <20130910135129.GP22421@suse.de>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1376025702-14818-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 09, 2013 at 01:21:34AM -0400, Naoya Horiguchi wrote:
> Before enabling each user of page migration to support hugepage,
> this patch enables the list of pages for migration to link not only
> LRU pages, but also hugepages. As a result, putback_movable_pages()
> and migrate_pages() can handle both of LRU pages and hugepages.
> 

LRU pages and *allocated* hugepages.

On its own the patch looks ok but it's not obvious at this point what
happens for pages that are on the hugetlbfs pool lists but not allocated
by any process. They will fail to isolate because of the
get_page_unless_zero() check. Maybe it's handled by a later patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
