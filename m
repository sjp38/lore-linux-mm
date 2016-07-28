Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3E3C6B0260
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:20:31 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so10515676lfb.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:20:31 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ld7si11548444wjb.76.2016.07.28.00.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 00:20:30 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i5so9751231wmg.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:20:30 -0700 (PDT)
Date: Thu, 28 Jul 2016 09:20:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] can we use vmalloc to alloc thread stack if compaction
 failed
Message-ID: <20160728072028.GC31860@dhcp22.suse.cz>
References: <5799AF6A.2070507@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5799AF6A.2070507@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>

On Thu 28-07-16 15:08:26, Xishi Qiu wrote:
> Usually THREAD_SIZE_ORDER is 2, it means we need to alloc 16kb continuous
> physical memory during fork a new process.
> 
> If the system's memory is very small, especially the smart phone, maybe there
> is only 1G memory. So the free memory is very small and compaction is not
> always success in slowpath(__alloc_pages_slowpath), then alloc thread stack
> may be failed for memory fragment.

Well, with the current implementation of the page allocator those
requests will not fail in most cases. The oom killer would be invoked in
order to free up some memory.

> Can we use vmalloc to alloc thread stack if compaction failed in slowpath?

Not yet but Andy is working on this.

> e.g. Use vmalloc as a fallback if alloc_page/kamlloc failed.
> 
> I think the performance may be a little regression, and any other problems?
> 
> Thanks,
> Xishi Qiu

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
