Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A5C726B0092
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:20:24 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so4695845pdi.38
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:20:24 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id pt8si6392236pac.76.2013.12.08.23.20.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 08 Dec 2013 23:20:23 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 9 Dec 2013 17:20:20 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C1C6B2BB0057
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 18:20:18 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB9722Lq8061388
	for <linux-mm@kvack.org>; Mon, 9 Dec 2013 18:02:08 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB97KBOf015934
	for <linux-mm@kvack.org>; Mon, 9 Dec 2013 18:20:11 +1100
Date: Mon, 9 Dec 2013 15:20:10 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 13/18] mm: numa: Make NUMA-migrate related functions
 static
Message-ID: <52a56f37.28dc420a.5f91.3c7fSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-14-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386572952-1191-14-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,
On Mon, Dec 09, 2013 at 07:09:07AM +0000, Mel Gorman wrote:
>numamigrate_update_ratelimit and numamigrate_isolate_page only have callers
>in mm/migrate.c. This patch makes them static.
>

I have already send out patches to fix this issue yesterday. ;-)

http://marc.info/?l=linux-mm&m=138648332222847&w=2
http://marc.info/?l=linux-mm&m=138648332422848&w=2

Regards,
Wanpeng Li 

>Signed-off-by: Mel Gorman <mgorman@suse.de>
>---
> mm/migrate.c | 5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
>
>diff --git a/mm/migrate.c b/mm/migrate.c
>index 5372521..77147bd 100644
>--- a/mm/migrate.c
>+++ b/mm/migrate.c
>@@ -1593,7 +1593,8 @@ bool migrate_ratelimited(int node)
> }
>
> /* Returns true if the node is migrate rate-limited after the update */
>-bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
>+static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
>+					unsigned long nr_pages)
> {
> 	bool rate_limited = false;
>
>@@ -1617,7 +1618,7 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
> 	return rate_limited;
> }
>
>-int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>+static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
> {
> 	int page_lru;
>
>-- 
>1.8.4
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
