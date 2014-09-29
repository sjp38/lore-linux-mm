Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id BBB266B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 03:25:37 -0400 (EDT)
Received: by mail-oi0-f49.google.com with SMTP id e131so2539044oig.8
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 00:25:37 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id m4si13291458obn.4.2014.09.29.00.25.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 00:25:37 -0700 (PDT)
Message-ID: <54290962.8010603@huawei.com>
Date: Mon, 29 Sep 2014 15:25:22 +0800
From: Zefan Li <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Simplify cpuset API and fix cpuset check in SL[AU]B
References: <cover.1411741632.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411741632.git.vdavydov@parallels.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka
 Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo
 Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 2014/9/26 22:50, Vladimir Davydov wrote:
> Hi,
> 
> SLAB and SLUB use hardwall cpuset check on fallback alloc, while the
> page allocator uses softwall check for all kernel allocations. This may
> result in falling into the page allocator even if there are free objects
> on other nodes. SLAB algorithm is especially affected: the number of
> objects allocated in vain is unlimited, so that they theoretically can
> eat up a whole NUMA node. For more details see comments to patches 3, 4.
> 
> When I last sent a fix (https://lkml.org/lkml/2014/8/10/100), David
> found the whole cpuset API being cumbersome and proposed to simplify it
> before getting to fixing its users. So this patch set addresses both
> David's complain (patches 1, 2) and the SL[AU]B issues (patches 3, 4).
> 
> Reviews are appreciated.
> 
> Thanks,
> 
> Vladimir Davydov (4):
>   cpuset: convert callback_mutex to a spinlock
>   cpuset: simplify cpuset_node_allowed API
>   slab: fix cpuset check in fallback_alloc
>   slub: fix cpuset check in get_any_partial
> 

Acked-by: Zefan Li <lizefan@huawei.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
