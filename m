Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 8465D6B0044
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 20:44:50 -0400 (EDT)
Message-ID: <5081F552.9060008@cn.fujitsu.com>
Date: Sat, 20 Oct 2012 08:50:26 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] acpi,memory-hotplug : implement framework for
 hot removing memory
References: <1350641040-19434-1-git-send-email-wency@cn.fujitsu.com> <10485269.ao9A69hu9S@vostro.rjw.lan>
In-Reply-To: <10485269.ao9A69hu9S@vostro.rjw.lan>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, liuj97@gmail.com, len.brown@intel.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, muneda.takahiro@jp.fujitsu.com

At 10/20/2012 12:32 AM, Rafael J. Wysocki Wrote:
> On Friday 19 of October 2012 18:03:57 wency@cn.fujitsu.com wrote:
>> From: Wen Congyang <wency@cn.fujitsu.com>
>>
>> The patch-set implements a framework for hot removing memory.
>>
>> The memory device can be removed by 2 ways:
>> 1. send eject request by SCI
>> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
>>
>> In the 1st case, acpi_memory_disable_device() will be called.
>> In the 2nd case, acpi_memory_device_remove() will be called.
>> acpi_memory_device_remove() will also be called when we unbind the
>> memory device from the driver acpi_memhotplug or a driver initialization
>> fails.
>>
>> acpi_memory_disable_device() has already implemented a code which
>> offlines memory and releases acpi_memory_info struct . But
>> acpi_memory_device_remove() has not implemented it yet.
>>
>> So the patch prepares the framework for hot removing memory and
>> adds the framework into acpi_memory_device_remove().
>>
>> The last version of this patchset is here:
>> https://lkml.org/lkml/2012/10/3/126
>>
>> Changelos from v1 to v2:
>>   Patch1: use acpi_bus_trim() instead of acpi_bus_remove()
>>   Patch2: new patch, introduce a lock to protect the list
>>   Patch3: remove memory too when type is ACPI_BUS_REMOVAL_NORMAL
>>   Note: I don't send [Patch2-4 v1] in this series because they
>>   are no logical changes in these 3 patches.
>>
>> Wen Congyang (2):
>>   acpi,memory-hotplug: call acpi_bus_trim() to remove memory device
>>   acpi,memory-hotplug: introduce a mutex lock to protect the list in
>>     acpi_memory_device
>>
>> Yasuaki Ishimatsu (1):
>>   acpi,memory-hotplug : add memory offline code to
>>     acpi_memory_device_remove()
>>
>>  drivers/acpi/acpi_memhotplug.c |   51 ++++++++++++++++++++++++++++++++--------
>>  1 files changed, 41 insertions(+), 10 deletions(-)
>>
>> --
> 
> Can you please tell me what kernel is the series supposed to apply to?
> Is it the current Linus' tree, or linux-next, or something else?

Current Linux's tree.

Thanks
Wen Congyang

> 
> Thanks,
> Rafael
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
