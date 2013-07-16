From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 02/10] mm: zone_reclaim: compaction: scan all memory with
 /proc/sys/vm/compact_memory
Date: Wed, 17 Jul 2013 07:29:30 +0800
Message-ID: <41006.1632203453$1374017392@news.gmane.org>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
 <1373982114-19774-3-git-send-email-aarcange@redhat.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UzEgi-0000V3-40
	for glkm-linux-mm-2@m.gmane.org; Wed, 17 Jul 2013 01:29:44 +0200
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 15C006B0034
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 19:29:42 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Jul 2013 09:20:08 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 3A05B2CE804A
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:29:32 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6GNEHex5243238
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:14:17 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6GNTViS005129
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:29:31 +1000
Content-Disposition: inline
In-Reply-To: <1373982114-19774-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Hush Bensen <hush.bensen@gmail.com>

On Tue, Jul 16, 2013 at 03:41:46PM +0200, Andrea Arcangeli wrote:
>Reset the stats so /proc/sys/vm/compact_memory will scan all memory.
>
>Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>Reviewed-by: Rik van Riel <riel@redhat.com>
>Acked-by: Rafael Aquini <aquini@redhat.com>
>Acked-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/compaction.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>
>diff --git a/mm/compaction.c b/mm/compaction.c
>index 05ccb4c..cac9594 100644
>--- a/mm/compaction.c
>+++ b/mm/compaction.c
>@@ -1136,12 +1136,14 @@ void compact_pgdat(pg_data_t *pgdat, int order)
>
> static void compact_node(int nid)
> {
>+	pg_data_t *pgdat = NODE_DATA(nid);
> 	struct compact_control cc = {
> 		.order = -1,
> 		.sync = true,
> 	};
>
>-	__compact_pgdat(NODE_DATA(nid), &cc);
>+	reset_isolation_suitable(pgdat);
>+	__compact_pgdat(pgdat, &cc);
> }
>
> /* Compact all nodes in the system */
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
