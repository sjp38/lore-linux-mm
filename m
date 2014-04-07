Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EC7456B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 04:25:19 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so6378538pab.23
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 01:25:19 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id nm5si8000079pbc.294.2014.04.07.01.25.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 01:25:19 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7C8F63EE0BC
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 17:25:17 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F8FE45DF56
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 17:25:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 583E745DF10
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 17:25:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4728E1DB804D
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 17:25:17 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF3751DB8047
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 17:25:16 +0900 (JST)
Message-ID: <5342608C.8010104@jp.fujitsu.com>
Date: Mon, 7 Apr 2014 17:23:40 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 0/1] mm: hugetlb: fix stalls when a large number of hugepages
 are freed
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, mhocko@suse.cz, liwanp@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, kosaki.motohiro@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com

Hi,

This patch will fix a long stalling when a large number of hugepages are freed.

* Changes in v2
- The subject is changed.
- Adding cond_resched_lock() in return_unused_surplus_pages().
  Because when freeing a number of surplus pages, same problems happen.

Thanks,
Masayoshi Mizuma

Masayoshi Mizuma (1):
      mm: hugetlb: fix stalling when a large number of hugepages are freed

 mm/hugetlb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
