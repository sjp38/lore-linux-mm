Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5D16B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:11:46 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so7480053pbc.26
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 04:11:45 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id hb3si10302491pac.36.2013.12.10.04.11.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 04:11:44 -0800 (PST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 22:11:39 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1E4413578023
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 23:11:36 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBABrNmO4915470
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 22:53:24 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBACBYth028365
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 23:11:34 +1100
Date: Tue, 10 Dec 2013 20:11:31 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 01/12] sched/numa: fix set cpupid on page migration
 twice against thp
Message-ID: <52a70500.e3bf420a.473e.ffffac70SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Ingo, is it ok for you to pick up this patchset?
On Tue, Dec 10, 2013 at 05:19:24PM +0800, Wanpeng Li wrote:
>commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over
>the cpupid at page migration time, there is unnecessary to set it again
>in function migrate_misplaced_transhuge_page, this patch fix it.
>
>Acked-by: Mel Gorman <mgorman@suse.de>
>Reviewed-by: Rik van Riel <riel@redhat.com>
>Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>---
> mm/migrate.c |    2 --
> 1 files changed, 0 insertions(+), 2 deletions(-)
>
>diff --git a/mm/migrate.c b/mm/migrate.c
>index bb94004..fdb70f7 100644
>--- a/mm/migrate.c
>+++ b/mm/migrate.c
>@@ -1736,8 +1736,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> 	if (!new_page)
> 		goto out_fail;
>
>-	page_cpupid_xchg_last(new_page, page_cpupid_last(page));
>-
> 	isolated = numamigrate_isolate_page(pgdat, page);
> 	if (!isolated) {
> 		put_page(new_page);
>-- 
>1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
