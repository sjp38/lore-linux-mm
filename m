Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 6235D6B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 02:40:26 -0400 (EDT)
Message-ID: <507276A7.8070503@cn.fujitsu.com>
Date: Mon, 08 Oct 2012 14:45:59 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] acpi,memory-hotplug : rename remove_memory() to offline_memory()
References: <506C0AE8.40702@jp.fujitsu.com> <506C0D45.3050909@jp.fujitsu.com> <CAHGf_=pdVLEkGDvbMC7vjd0F8Y_YFdKX85YcLwR+gCQ8Tf2Mcw@mail.gmail.com>
In-Reply-To: <CAHGf_=pdVLEkGDvbMC7vjd0F8Y_YFdKX85YcLwR+gCQ8Tf2Mcw@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

At 10/05/2012 05:31 AM, KOSAKI Motohiro Wrote:
> On Wed, Oct 3, 2012 at 6:02 AM, Yasuaki Ishimatsu
> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> add_memory() hot adds a physical memory. But remove_memory does not
>> hot remove a phsical memory. It only offlines memory. The name
>> confuse us.
>>
>> So the patch renames remove_memory() to offline_memory(). We will
>> use rename_memory() for hot removing memory.
>>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>> ---
>>  drivers/acpi/acpi_memhotplug.c |    2 +-
>>  include/linux/memory_hotplug.h |    2 +-
>>  mm/memory_hotplug.c            |    6 +++---
>>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> Probably, the better way is to just remove remove_memory() and use
> offline_pages().

we don't notify the userspace that the memory is offlined in offline_pages().
We reimplement offline_memory(), but ishimatsu doesn't include that patch to
this series.

Thanks
Wen Congyang

> 
> btw, current remove_memory() pfn calculation is just buggy.
> 
> 
>> int remove_memory(u64 start, u64 size)
>> {
>> 	unsigned long start_pfn, end_pfn;
>>
>> 	start_pfn = PFN_DOWN(start);
>> 	end_pfn = start_pfn + PFN_DOWN(size);
> 
> It should be:
> 
> 	start_pfn = PFN_DOWN(start);
> 	end_pfn = PFN_UP(start + size)
> 
> or
> 
> 	start_pfn = PFN_UP(start);
> 	end_pfn = PFN_DOWN(start + size)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
