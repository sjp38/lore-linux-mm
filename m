Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D805B6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:20:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so39894929pfg.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:20:06 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id g63si10989678pfb.36.2016.07.28.00.16.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jul 2016 00:20:06 -0700 (PDT)
Message-ID: <5799AF6A.2070507@huawei.com>
Date: Thu, 28 Jul 2016 15:08:26 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] can we use vmalloc to alloc thread stack if compaction failed
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Usually THREAD_SIZE_ORDER is 2, it means we need to alloc 16kb continuous
physical memory during fork a new process.

If the system's memory is very small, especially the smart phone, maybe there
is only 1G memory. So the free memory is very small and compaction is not
always success in slowpath(__alloc_pages_slowpath), then alloc thread stack
may be failed for memory fragment.

Can we use vmalloc to alloc thread stack if compaction failed in slowpath?
e.g. Use vmalloc as a fallback if alloc_page/kamlloc failed.

I think the performance may be a little regression, and any other problems?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
