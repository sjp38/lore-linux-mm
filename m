Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 119346B0126
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 17:17:17 -0400 (EDT)
Received: by mail-qe0-f47.google.com with SMTP id w7so2278509qeb.6
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 14:17:17 -0700 (PDT)
Message-ID: <515F3F5C.2090709@gmail.com>
Date: Fri, 05 Apr 2013 17:17:16 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] migrate: add hugepage migration code to migrate_pages()
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(3/22/13 4:23 PM), Naoya Horiguchi wrote:
> This patch extends check_range() to handle vma with VM_HUGETLB set.
> We will be able to migrate hugepage with migrate_pages(2) after
> applying the enablement patch which comes later in this series.
> 
> Note that for larger hugepages (covered by pud entries, 1GB for
> x86_64 for example), we simply skip it now.

check_range() has largely duplication with mm_walk and it is quirk subset.
Instead of, could you replace them to mm_walk and enhance/cleanup mm_walk?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
