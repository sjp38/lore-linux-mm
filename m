Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 9B0B56B0070
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 04:06:37 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B0BF23EE0C0
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:06:35 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9712645DE5A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:06:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78A9E45DE58
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:06:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 550331DB8054
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:06:35 +0900 (JST)
Received: from g01jpexchkw30.g01.fujitsu.local (g01jpexchkw30.g01.fujitsu.local [10.0.193.113])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 066021DB804B
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 17:06:35 +0900 (JST)
Message-ID: <508109F2.1080402@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 17:06:10 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/9] bugfix for memory hotplug
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

Some bug fix patches have been merged into linux-next.
So the patches confuse me.
Why did you send same patches again?

Thanks,
Yasuaki Ishimatsu

2012/10/19 15:46, wency@cn.fujitsu.com wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
> 
> Changes from v2 to v3:
>    Merge the bug fix from ishimatsu to this patchset(Patch 1-3)
>    Patch 3: split it from patch as it fixes another bug.
>    Patch 4: new patch, and fix bad-page state when hotadding a memory
>             device after hotremoving it. I forgot to post this patch in v2.
>    Patch 6: update it according to Dave Hansen's comment.
> 
> Changes from v1 to v2:
>    Patch 1: updated according to kosaki's suggestion
> 
>    Patch 2: new patch, and update mce_bad_pages when removing memory.
> 
>    Patch 4: new patch, and fix a NR_FREE_PAGES mismatch, and this bug
>             cause oom in my test.
> 
>    Patch 5: new patch, and fix a new bug. When repeating to online/offline
>             pages, the free pages will continue to decrease.
> 
> Wen Congyang (6):
>    clear the memory to store struct page
>    memory-hotplug: skip HWPoisoned page when offlining pages
>    memory-hotplug: update mce_bad_pages when removing the memory
>    memory-hotplug: auto offline page_cgroup when onlining memory block
>      failed
>    memory-hotplug: fix NR_FREE_PAGES mismatch
>    memory-hotplug: allocate zone's pcp before onlining pages
> 
> Yasuaki Ishimatsu (3):
>    suppress "Device memoryX does not have a release() function" warning
>    suppress "Device nodeX does not have a release() function" warning
>    memory-hotplug: flush the work for the node when the node is offlined
> 
>   drivers/base/memory.c          |    9 ++++++++-
>   drivers/base/node.c            |   11 +++++++++++
>   include/linux/page-isolation.h |   10 ++++++----
>   mm/memory-failure.c            |    2 +-
>   mm/memory_hotplug.c            |   14 ++++++++------
>   mm/page_alloc.c                |   37 ++++++++++++++++++++++++++++---------
>   mm/page_cgroup.c               |    3 +++
>   mm/page_isolation.c            |   27 ++++++++++++++++++++-------
>   mm/sparse.c                    |   22 +++++++++++++++++++++-
>   9 files changed, 106 insertions(+), 29 deletions(-)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
