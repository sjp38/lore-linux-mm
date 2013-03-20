Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 7DBD16B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 05:36:05 -0400 (EDT)
Received: by mail-da0-f47.google.com with SMTP id s35so878264dak.34
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 02:36:04 -0700 (PDT)
Date: Wed, 20 Mar 2013 17:35:36 +0800
From: Wang YanQing <udknight@gmail.com>
Subject: [RFC]about commit "[PATCH] Align the node_mem_map endpoints to a
 MAX_ORDER boundary"
Message-ID: <20130320093536.GA2295@udknight>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org, bob.picco@hp.com

Hi Mel Gorman and all, could you explain the code snippet below in
commit e984bb43f7450312ba66fe0e67a99efa6be3b246
"[PATCH] Align the node_mem_map endpoints to a MAX_ORDER boundary"
this commit had getted your ack-by.

"
start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
end = ALIGN(end, MAX_ORDER_NR_PAGES);
size =  (end - start) * sizeof(struct page);
map = alloc_remap(pgdat->node_id, size);
if (!map)
        map = alloc_bootmem_node(pgdat, size);
pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
"


MY QUESTION IS WHY WE NEED THIS TWO LINES BELOW:

"
start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
"
and
"
pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
"

Maybe we don't need this trick and can save some hundred bytes.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
