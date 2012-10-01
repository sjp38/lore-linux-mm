Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id BF15D6B002B
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 03:39:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 018553EE0C3
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 16:39:22 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D940745DEB5
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 16:39:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BF49A45DEB6
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 16:39:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AE96F1DB8042
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 16:39:22 +0900 (JST)
Received: from g01jpexchkw04.g01.fujitsu.local (g01jpexchkw04.g01.fujitsu.local [10.0.194.43])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 690EA1DB803C
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 16:39:22 +0900 (JST)
Message-ID: <50694884.7090706@jp.fujitsu.com>
Date: Mon, 1 Oct 2012 16:38:44 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v9 PATCH 03/21] memory-hotplug: store the node id in acpi_memory_device
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com> <1346837155-534-4-git-send-email-wency@cn.fujitsu.com> <506517C1.7050909@gmail.com>
In-Reply-To: <506517C1.7050909@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: wency@cn.fujitsu.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Chen,

2012/09/28 12:21, Ni zhan Chen wrote:
> On 09/05/2012 05:25 PM, wency@cn.fujitsu.com wrote:
>> From: Wen Congyang <wency@cn.fujitsu.com>
>>
>> The memory device has only one node id. Store the node id when
>> enable the memory device, and we can reuse it when removing the
>> memory device.
>
> one question:
> if use numa emulation, memory device will associated to one node or ...?

Memory device has only one node, even if you use numa emulation.

Thanks,
Yasuaki Ishimatsu

>
>>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: Paul Mackerras <paulus@samba.org>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> ---
>>   drivers/acpi/acpi_memhotplug.c |    4 ++++
>>   1 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
>> index 2a7beac..7873832 100644
>> --- a/drivers/acpi/acpi_memhotplug.c
>> +++ b/drivers/acpi/acpi_memhotplug.c
>> @@ -83,6 +83,7 @@ struct acpi_memory_info {
>>   struct acpi_memory_device {
>>       struct acpi_device * device;
>>       unsigned int state;    /* State of the memory device */
>> +    int nid;
>>       struct list_head res_list;
>>   };
>> @@ -256,6 +257,9 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>>           info->enabled = 1;
>>           num_enabled++;
>>       }
>> +
>> +    mem_device->nid = node;
>> +
>>       if (!num_enabled) {
>>           printk(KERN_ERR PREFIX "add_memory failed\n");
>>           mem_device->state = MEMORY_INVALID_STATE;
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
