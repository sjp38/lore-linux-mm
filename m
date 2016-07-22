Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 05AC46B025E
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 23:31:57 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so172269260pap.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 20:31:56 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id c10si13398877pan.75.2016.07.21.20.31.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 20:31:56 -0700 (PDT)
Message-ID: <579191F1.1060407@huawei.com>
Date: Fri, 22 Jul 2016 11:24:33 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: An question about too1/vm/page-types
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com, dyoung@redhat.com, Michal Hocko <mhocko@kernel.org>, mgorman@techsingularity.net, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Linux Memory Management List <linux-mm@kvack.org>

Hi, guys

the page range from 160 to 192 corresponding to the physcial address from a0000  to bffff.
That address space belongs to the PCI Bus we can get from the /proc/iomem.
we konw that the region may exist valid page struct, but PG_RESERVED should be set.
is right?  but  the actual is that page range is not any flag.  I don't understand.

[root@localhost vm]# ./page-types -a 160,192
             flags      page-count       MB  symbolic-flags                     long-symbolic-flags
0x0000000000000000              32        0  __________________________________________
             total              32        0

[root@localhost vm]# cat /proc/iomem | head -n5
00000000-00000fff : reserved
00001000-0009a7ff : System RAM
0009a800-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c7fff : Video ROM

Thanks
zhongjiang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
