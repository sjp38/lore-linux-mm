Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 387E46B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:00:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x85so11727844oix.3
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 01:00:23 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id j41si506913otb.154.2017.09.26.01.00.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 01:00:22 -0700 (PDT)
Message-ID: <59CA0847.8000508@huawei.com>
Date: Tue, 26 Sep 2017 15:56:55 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] a question about mlockall() and mprotect()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>, yeyunfeng <yeyunfeng@huawei.com>, wanghaitao12@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>

When we call mlockall(), we will add VM_LOCKED to the vma,
if the vma prot is ---p, then mm_populate -> get_user_pages
will not alloc memory.

I find it said "ignore errors" in mm_populate()
static inline void mm_populate(unsigned long addr, unsigned long len)
{
	/* Ignore errors */
	(void) __mm_populate(addr, len, 1);
}

And later we call mprotect() to change the prot, then it is
still not alloc memory for the mlocked vma.

My question is that, shall we alloc memory if the prot changed,
and who(kernel, glibc, user) should alloc the memory?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
