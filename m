Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 75AA46B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 04:02:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p9so79853326pfj.8
        for <linux-mm@kvack.org>; Tue, 02 May 2017 01:02:10 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id p12si6136254pli.219.2017.05.02.01.02.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 01:02:09 -0700 (PDT)
Message-ID: <59083C5B.5080204@huawei.com>
Date: Tue, 2 May 2017 15:59:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] dev/mem: "memtester -p 0x6c80000000000 10G" cause crash
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Michal
 Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shakeel Butt <shakeelb@google.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

Hi, I use "memtester -p 0x6c80000000000 10G" to test physical address 0x6c80000000000
Because this physical address is invalid, and valid_mmap_phys_addr_range()
always return 1, so it causes crash.

My question is that should the user assure the physical address is valid?

...
[ 169.147578] ? panic+0x1f1/0x239
[ 169.150789] oops_end+0xb8/0xd0
[ 169.153910] pgtable_bad+0x8a/0x95
[ 169.157294] __do_page_fault+0x3aa/0x4a0
[ 169.161194] do_page_fault+0x30/0x80
[ 169.164750] ? do_syscall_64+0x175/0x180
[ 169.168649] page_fault+0x28/0x30

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
