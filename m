Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id E41F66B005A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 11:31:20 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so8281294pbb.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 08:31:20 -0700 (PDT)
Message-ID: <507ECF49.7050003@gmail.com>
Date: Wed, 17 Oct 2012 23:31:21 +0800
From: Wen Congyang <wencongyang@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] bugfix for memory hotplug
References: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com> <507EA308.9090106@gmail.com>
In-Reply-To: <507EA308.9090106@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

At 2012/10/17 20:22, Ni zhan Chen Wrote:
> On 10/17/2012 08:08 PM, wency@cn.fujitsu.com wrote:
>> From: Wen Congyang <wency@cn.fujitsu.com>
>>
>> Wen Congyang (5):
>> memory-hotplug: skip HWPoisoned page when offlining pages
>> memory-hotplug: update mce_bad_pages when removing the memory
>> memory-hotplug: auto offline page_cgroup when onlining memory block
>> failed
>> memory-hotplug: fix NR_FREE_PAGES mismatch
>> memory-hotplug: allocate zone's pcp before onlining pages
>
> Oops, why you don't write changelog?

I forgot to add it. Here is the changelog:

Patch 1: updated according to kosaki's suggestion

Patch 2: new patch, and update mce_bad_pages when removing memory.

Patch 4: new patch, and fix a NR_FREE_PAGES mismatch, and this bug
cause oom in my test.

Patch 5: new patch, and fix a new bug. When repeating to online/offline
pages, the free pages will continue to decrease.

>
>>
>> include/linux/page-isolation.h | 10 ++++++----
>> mm/memory-failure.c | 2 +-
>> mm/memory_hotplug.c | 14 ++++++++------
>> mm/page_alloc.c | 37 ++++++++++++++++++++++++++++---------
>> mm/page_cgroup.c | 3 +++
>> mm/page_isolation.c | 27 ++++++++++++++++++++-------
>> mm/sparse.c | 21 +++++++++++++++++++++
>> 7 files changed, 87 insertions(+), 27 deletions(-)
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
