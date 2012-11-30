Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 9735F6B006E
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 01:38:44 -0500 (EST)
Message-ID: <50B85435.8020907@cn.fujitsu.com>
Date: Fri, 30 Nov 2012 14:37:41 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v4 00/12] memory-hotplug: hot-remove physical memory
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com> <20121127112741.b616c2f6.akpm@linux-foundation.org>
In-Reply-To: <20121127112741.b616c2f6.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

Hi Andrew,

On 11/28/2012 03:27 AM, Andrew Morton wrote:
>>
>> - acpi framework
>>    https://lkml.org/lkml/2012/10/26/175
>
> What's happening with the acpi framework?  has it received any feedback
> from the ACPI developers?

About ACPI framework, we are trying to do the following.

     The memory device can be removed by 2 ways:
     1. send eject request by SCI
     2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

     In the 1st case, acpi_memory_disable_device() will be called.
     In the 2nd case, acpi_memory_device_remove() will be called.
     acpi_memory_device_remove() will also be called when we unbind the
     memory device from the driver acpi_memhotplug or a driver
     initialization fails.

     acpi_memory_disable_device() has already implemented a code which
     offlines memory and releases acpi_memory_info struct . But
     acpi_memory_device_remove() has not implemented it yet.

     So the patch prepares the framework for hot removing memory and
     adds the framework into acpi_memory_device_remove().

All the ACPI related patches have been put into the linux-next branch
of the linux-pm.git tree as v3.8 material.Please refer to the following
url.
https://lkml.org/lkml/2012/11/2/160

So for now, with this patch set, we can do memory hot-remove on x86_64
linux.

I do hope you would merge them before 3.8-rc1, so that we can use this
functionality in 3.8.

As we are still testing all memory hotplug related functionalities, I
hope we can do the bug fix during 3.8 rc.

Thanks. :)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
