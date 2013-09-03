Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9F64E6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 00:58:29 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 10:18:27 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id E228CE004F
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 10:29:06 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r834wLQf36896948
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 10:28:21 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r834wNqt018710
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 10:28:23 +0530
Date: Tue, 3 Sep 2013 12:58:22 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: compaction: update comment about zone lock in
 isolate_freepages_block
Message-ID: <20130903045822.GA5548@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377871648-9930-1-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377871648-9930-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

On Fri, Aug 30, 2013 at 04:07:28PM +0200, Jerome Marchand wrote:
>Since commit f40d1e4 (mm: compaction: acquire the zone->lock as late as
>possible), isolate_freepages_block() takes the zone->lock itself. The
>function description however still states that the zone->lock must be
>held.
>This patch removes this outdated statement.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>---
> mm/compaction.c |    7 +++----
> 1 files changed, 3 insertions(+), 4 deletions(-)
>
>diff --git a/mm/compaction.c b/mm/compaction.c
>index 05ccb4c..9f9026f 100644
>--- a/mm/compaction.c
>+++ b/mm/compaction.c
>@@ -235,10 +235,9 @@ static bool suitable_migration_target(struct page *page)
> }
>
> /*
>- * Isolate free pages onto a private freelist. Caller must hold zone->lock.
>- * If @strict is true, will abort returning 0 on any invalid PFNs or non-free
>- * pages inside of the pageblock (even though it may still end up isolating
>- * some pages).
>+ * Isolate free pages onto a private freelist. If @strict is true, will abort
>+ * returning 0 on any invalid PFNs or non-free pages inside of the pageblock
>+ * (even though it may still end up isolating some pages).
>  */
> static unsigned long isolate_freepages_block(struct compact_control *cc,
> 				unsigned long blockpfn,
>-- 
>1.7.7.6
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
