Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 2E7966B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 01:53:02 -0400 (EDT)
Message-ID: <51FB48E5.6040007@cn.fujitsu.com>
Date: Fri, 02 Aug 2013 13:51:33 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 13/18] x86, numa, mem_hotplug: Skip all the regions
 the kernel resides in.
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com> <1375340800-19332-14-git-send-email-tangchen@cn.fujitsu.com> <20130801134218.GA29323@htj.dyndns.org>
In-Reply-To: <20130801134218.GA29323@htj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 08/01/2013 09:42 PM, Tejun Heo wrote:
>> On Thu, Aug 01, 2013 at 03:06:35PM +0800, Tang Chen wrote:
>>
>> At early time, memblock will reserve some memory for the kernel,
>> such as the kernel code and data segments, initrd file, and so on=EF=BC=8C
>> which means the kernel resides in these memory regions.
>>
>> Even if these memory regions are hotpluggable, we should not
>> mark them as hotpluggable. Otherwise the kernel won't have enough
>> memory to boot.
>>
>> This patch finds out which memory regions the kernel resides in,
>> and skip them when finding all hotpluggable memory regions.
>>
>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>> Reviewed-by: Zhang Yanfei<zhangyanfei@cn.fujitsu.com>
>> ---
>>   mm/memory=5Fhotplug.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
>>    1 files changed, 45 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory=5Fhotplug.c b/mm/memory=5Fhotplug.c
>> index 326e2f2..b800c9c 100644
>> --- a/mm/memory=5Fhotplug.c
>> +++ b/mm/memory=5Fhotplug.c
>> @@ -31,6 +31,7 @@
>>   #include<linux/firmware-map.h>
>>   #include<linux/stop=5Fmachine.h>
>>   #include<linux/acpi.h>
>> +#include<linux/memblock.h>
>> =20
>>   #include<asm/tlbflush.h>
>> =20
>
> This patch is contaminated.  Can you please resend?It

It's wired. I'll rebase these patches to linux 3.11-rc3 and resend them all.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
