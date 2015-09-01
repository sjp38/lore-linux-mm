Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2096B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 17:54:29 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so8612883pac.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 14:54:29 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id aj2si28689000pad.17.2015.09.01.14.54.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 14:54:28 -0700 (PDT)
Received: by padhy1 with SMTP id hy1so8627352pad.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 14:54:28 -0700 (PDT)
Date: Tue, 1 Sep 2015 14:54:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] mm: fix type information of memoryless node
In-Reply-To: <1440833685-32372-1-git-send-email-thunder.leizhen@huawei.com>
Message-ID: <alpine.DEB.2.10.1509011454170.691@chino.kir.corp.google.com>
References: <1440833685-32372-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhen Lei <thunder.leizhen@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Sat, 29 Aug 2015, Zhen Lei wrote:

> For a memoryless node, the output of get_pfn_range_for_nid are all zero.
> It will display mem from 0 to -1.
> 
> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
