Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2C72C6B006E
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 08:20:07 -0400 (EDT)
Received: by layy10 with SMTP id y10so78759368lay.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:20:06 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id r1si2764615wic.9.2015.04.17.05.20.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 05:20:05 -0700 (PDT)
Received: by widdi4 with SMTP id di4so19653904wid.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:20:04 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 17 Apr 2015 20:20:04 +0800
Message-ID: <CADUS3okX90JX3KfCf8zHvxY12b=QiU25jQBioh8LrEDVF56A-A@mail.gmail.com>
Subject: about bootmem allocation/freeing flow
From: yoma sophian <sophian.yoma@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

hi all:
I have several questions about free_all_bootmem_core:

1.
In __free_pages_bootmem, we set set_page_count(p, 0) while looping nr_pages,
why we need to set_page_refcounted(page) before calling __free_pages?

2.
how about the pages that allocated by calling alloc_bootmem_xxxx?
in  free_all_bootmem, we just free the pages that used to record
bootmem stage present pages like below.
if so, isn't possible the pages got by calling alloc_bootmem_xxxx will
be over-written by later page allocation ?
    page = virt_to_page(bdata->node_bootmem_map);
    pages = bdata->node_low_pfn - bdata->node_min_pfn;
    pages = bootmem_bootmap_pages(pages);
    count += pages;
    while (pages--)
        __free_pages_bootmem(page++, 0);

appreciate your kind help in advance,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
