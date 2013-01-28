Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 697FC6B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 20:23:05 -0500 (EST)
Message-ID: <5105D2C8.1000807@cn.fujitsu.com>
Date: Mon, 28 Jan 2013 09:22:16 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH Bug fix 0/5] Bug fix for physical memory hot-remove.
References: <1358854984-6073-1-git-send-email-tangchen@cn.fujitsu.com> <1359137977.14145.417.camel@misato.fc.hp.com>
In-Reply-To: <1359137977.14145.417.camel@misato.fc.hp.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

On 01/26/2013 02:19 AM, Toshi Kani wrote:
> On Tue, 2013-01-22 at 19:42 +0800, Tang Chen wrote:
>> Here are some bug fix patches for physical memory hot-remove. All these
>> patches are based on the latest -mm tree.
>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm
>>
>> And patch1 and patch3 are very important.
>> patch1: free compound pages when freeing memmap, otherwise the kernel
>>          will panic the next time memory is hot-added.
>> patch3: the old way of freeing pagetable pages was wrong. We should never
>>          split larger pages into small ones.
>>
>>
>> Lai Jiangshan (1):
>>    Bug-fix: mempolicy: fix is_valid_nodemask()
>>
>> Tang Chen (3):
>>    Bug fix: Do not split pages when freeing pagetable pages.
>>    Bug fix: Fix section mismatch problem of
>>      release_firmware_map_entry().
>>    Bug fix: Fix the doc format in drivers/firmware/memmap.c
>>
>> Wen Congyang (1):
>>    Bug fix: consider compound pages when free memmap
>>
>>   arch/x86/mm/init_64.c     |  148 ++++++++++++++-------------------------------
>>   drivers/firmware/memmap.c |   16 +++---
>>   mm/mempolicy.c            |   36 +++++++----
>>   mm/sparse.c               |    2 +-
>>   4 files changed, 77 insertions(+), 125 deletions(-)
>
> This patchset fixed a blocker panic I was hitting in my memory hot-plug
> testing.  Memory hotplug works fine with this patchset (for testing my
> hotplug framework patchset :).  For the series:

Hi Toshi-san,

Thank you for testing. :)

>
> Tested-by: Toshi Kani<toshi.kani@hp.com>
>
> Thanks,
> -Toshi
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
