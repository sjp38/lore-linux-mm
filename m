Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6ED6B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 16:42:08 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so2989872pbc.4
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 13:42:07 -0700 (PDT)
Date: Thu, 3 Oct 2013 13:42:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/sparsemem: Fix a bug in free_map_bootmem when
 CONFIG_SPARSEMEM_VMEMMAP
Message-Id: <20131003134204.e408977b42cb85984473cfd6@linux-foundation.org>
In-Reply-To: <524CE532.1030001@gmail.com>
References: <524CE4C1.8060508@gmail.com>
	<524CE532.1030001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, isimatu.yasuaki@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, 03 Oct 2013 11:32:02 +0800 Zhang Yanfei <zhangyanfei.yes@gmail.com> wrote:

> We pass the number of pages which hold page structs of a memory
> section to function free_map_bootmem. This is right when
> !CONFIG_SPARSEMEM_VMEMMAP but wrong when CONFIG_SPARSEMEM_VMEMMAP.
> When CONFIG_SPARSEMEM_VMEMMAP, we should pass the number of pages
> of a memory section to free_map_bootmem.
> 
> So the fix is removing the nr_pages parameter. When
> CONFIG_SPARSEMEM_VMEMMAP, we directly use the prefined marco
> PAGES_PER_SECTION in free_map_bootmem. When !CONFIG_SPARSEMEM_VMEMMAP,
> we calculate page numbers needed to hold the page structs for a
> memory section and use the value in free_map_bootmem.

What were the runtime user-visible effects of that bug?

Please always include this information when fixing a bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
