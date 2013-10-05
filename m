Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 60DDF6B0031
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 12:46:10 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5293231pbb.41
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 09:46:10 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so5401071pdj.29
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 09:46:07 -0700 (PDT)
Message-ID: <52504239.8090803@gmail.com>
Date: Sun, 06 Oct 2013 00:45:45 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/sparsemem: Fix a bug in free_map_bootmem when
 CONFIG_SPARSEMEM_VMEMMAP
References: <524CE4C1.8060508@gmail.com> <524CE532.1030001@gmail.com> <20131003134204.e408977b42cb85984473cfd6@linux-foundation.org>
In-Reply-To: <20131003134204.e408977b42cb85984473cfd6@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, isimatu.yasuaki@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hello andrew,

On 10/04/2013 04:42 AM, Andrew Morton wrote:
> On Thu, 03 Oct 2013 11:32:02 +0800 Zhang Yanfei <zhangyanfei.yes@gmail.com> wrote:
> 
>> We pass the number of pages which hold page structs of a memory
>> section to function free_map_bootmem. This is right when
>> !CONFIG_SPARSEMEM_VMEMMAP but wrong when CONFIG_SPARSEMEM_VMEMMAP.
>> When CONFIG_SPARSEMEM_VMEMMAP, we should pass the number of pages
>> of a memory section to free_map_bootmem.
>>
>> So the fix is removing the nr_pages parameter. When
>> CONFIG_SPARSEMEM_VMEMMAP, we directly use the prefined marco
>> PAGES_PER_SECTION in free_map_bootmem. When !CONFIG_SPARSEMEM_VMEMMAP,
>> we calculate page numbers needed to hold the page structs for a
>> memory section and use the value in free_map_bootmem.
> 
> What were the runtime user-visible effects of that bug?
> 
> Please always include this information when fixing a bug.


Sorry....This was found by reading the code. And I have no machine that
support memory hot-remove to test the bug now. But I believe it is a bug.

BTW, I've made a mistake in this patch which was found by wanpeng. I'll
send v2.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
