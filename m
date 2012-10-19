Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 378B46B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 04:40:07 -0400 (EDT)
Message-ID: <50811336.7070704@cn.fujitsu.com>
Date: Fri, 19 Oct 2012 16:45:42 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/9] bugfix for memory hotplug
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com> <508109F2.1080402@jp.fujitsu.com> <50810D14.8020609@jp.fujitsu.com>
In-Reply-To: <50810D14.8020609@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 10/19/2012 04:19 PM, Yasuaki Ishimatsu Wrote:
> 2012/10/19 17:06, Yasuaki Ishimatsu wrote:
>> Hi Wen,
>>
>> Some bug fix patches have been merged into linux-next.
>> So the patches confuse me.

Sorry, I don't check linux-next tree.

> 
> The following patches have been already merged into linux-next
> and mm-tree as long as I know. 
> 
>>> Wen Congyang (6):
>>>     clear the memory to store struct page
> 
> 
>>>     memory-hotplug: skip HWPoisoned page when offlining pages
> 
> mm-tree

Hmm, I don't find this patch in this URL:
http://www.ozlabs.org/~akpm/mmotm/broken-out/

Do I miss something?

> 
>>>     memory-hotplug: update mce_bad_pages when removing the memory
> 
>>>     memory-hotplug: auto offline page_cgroup when onlining memory block
>>>       failed
> 
> mm-tree
> 
>>>     memory-hotplug: fix NR_FREE_PAGES mismatch
> 
> mm-tree
> 
>>>     memory-hotplug: allocate zone's pcp before onlining pages
> 
> mm-tree
> 
>>>
>>> Yasuaki Ishimatsu (3):
>>>     suppress "Device memoryX does not have a release() function" warning
> 
> linux-next
> 
>>>     suppress "Device nodeX does not have a release() function" warning
>>>     memory-hotplug: flush the work for the node when the node is offlined
> 
> linux-next

I split this patch to two patches according to kosaki's comment.

Thanks
Wen Congyang

> 
> Thanks,
> Yasuaki Ishimatsu
> 
>> Why did you send same patches again?
>>
>> Thanks,
>> Yasuaki Ishimatsu
>>
>> 2012/10/19 15:46, wency@cn.fujitsu.com wrote:
>>> From: Wen Congyang <wency@cn.fujitsu.com>
>>>
>>> Changes from v2 to v3:
>>>     Merge the bug fix from ishimatsu to this patchset(Patch 1-3)
>>>     Patch 3: split it from patch as it fixes another bug.
>>>     Patch 4: new patch, and fix bad-page state when hotadding a memory
>>>              device after hotremoving it. I forgot to post this patch in v2.
>>>     Patch 6: update it according to Dave Hansen's comment.
>>>
>>> Changes from v1 to v2:
>>>     Patch 1: updated according to kosaki's suggestion
>>>
>>>     Patch 2: new patch, and update mce_bad_pages when removing memory.
>>>
>>>     Patch 4: new patch, and fix a NR_FREE_PAGES mismatch, and this bug
>>>              cause oom in my test.
>>>
>>>     Patch 5: new patch, and fix a new bug. When repeating to online/offline
>>>              pages, the free pages will continue to decrease.
>>>
>>> Wen Congyang (6):
>>>     clear the memory to store struct page
>>>     memory-hotplug: skip HWPoisoned page when offlining pages
>>>     memory-hotplug: update mce_bad_pages when removing the memory
>>>     memory-hotplug: auto offline page_cgroup when onlining memory block
>>>       failed
>>>     memory-hotplug: fix NR_FREE_PAGES mismatch
>>>     memory-hotplug: allocate zone's pcp before onlining pages
>>>
>>> Yasuaki Ishimatsu (3):
>>>     suppress "Device memoryX does not have a release() function" warning
>>>     suppress "Device nodeX does not have a release() function" warning
>>>     memory-hotplug: flush the work for the node when the node is offlined
>>>
>>>    drivers/base/memory.c          |    9 ++++++++-
>>>    drivers/base/node.c            |   11 +++++++++++
>>>    include/linux/page-isolation.h |   10 ++++++----
>>>    mm/memory-failure.c            |    2 +-
>>>    mm/memory_hotplug.c            |   14 ++++++++------
>>>    mm/page_alloc.c                |   37 ++++++++++++++++++++++++++++---------
>>>    mm/page_cgroup.c               |    3 +++
>>>    mm/page_isolation.c            |   27 ++++++++++++++++++++-------
>>>    mm/sparse.c                    |   22 +++++++++++++++++++++-
>>>    9 files changed, 106 insertions(+), 29 deletions(-)
>>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
