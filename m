Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id B9A106B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 21:44:29 -0400 (EDT)
Message-ID: <5080B1CD.6030008@cn.fujitsu.com>
Date: Fri, 19 Oct 2012 09:50:05 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] acpi,memory-hotplug : call acpi_bus_remo() to remove
 memory device
References: <506CE9F5.8020809@jp.fujitsu.com>	<506CEADA.9060108@jp.fujitsu.com> <CAE9FiQWaESFEBp+7w+E-ZfjgG4YFSTREoKfjNWNiOyhntf=uzg@mail.gmail.com>
In-Reply-To: <CAE9FiQWaESFEBp+7w+E-ZfjgG4YFSTREoKfjNWNiOyhntf=uzg@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, len.brown@intel.com

At 10/04/2012 10:41 AM, Yinghai Lu Wrote:
> On Wed, Oct 3, 2012 at 6:48 PM, Yasuaki Ishimatsu
> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>> From: Wen Congyang <wency@cn.fujitsu.com>
>>
>> The memory device has been ejected and powoffed, so we can call
>> acpi_bus_remove() to remove the memory device from acpi bus.
>>
>> CC: Len Brown <len.brown@intel.com>
>> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>> ---
>>  drivers/acpi/acpi_memhotplug.c |    3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> Index: linux-3.6/drivers/acpi/acpi_memhotplug.c
>> ===================================================================
>> --- linux-3.6.orig/drivers/acpi/acpi_memhotplug.c       2012-10-03 18:17:47.802249170 +0900
>> +++ linux-3.6/drivers/acpi/acpi_memhotplug.c    2012-10-03 18:17:52.471250299 +0900
>> @@ -424,8 +424,9 @@ static void acpi_memory_device_notify(ac
>>                 }
>>
>>                 /*
>> -                * TBD: Invoke acpi_bus_remove to cleanup data structures
>> +                * Invoke acpi_bus_remove() to remove memory device
>>                  */
>> +               acpi_bus_remove(device, 1);
> 
> why not using acpi_bus_trim instead?

Sorry for late reply. It's OK to use acpi_bus_trim(), and I will
update this patch soon.

Thanks
Wen Congyang

> 
> Yinghai
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
