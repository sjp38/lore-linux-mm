Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 182976B006C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 20:29:58 -0500 (EST)
Message-ID: <50A4444A.7050305@cn.fujitsu.com>
Date: Thu, 15 Nov 2012 09:24:26 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v4 1/7] acpi,memory-hotplug: introduce a mutex lock to
 protect the list in acpi_memory_device
References: <1352372693-32411-1-git-send-email-wency@cn.fujitsu.com> <1352754038.12509.16.camel@misato.fc.hp.com> <50A1AAC5.8000506@cn.fujitsu.com> <2008916.VzTIR8JBPq@vostro.rjw.lan>
In-Reply-To: <2008916.VzTIR8JBPq@vostro.rjw.lan>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Toshi Kani <toshi.kani@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jiang Liu <liuj97@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>

At 11/15/2012 07:34 AM, Rafael J. Wysocki Wrote:
> On Tuesday, November 13, 2012 10:04:53 AM Wen Congyang wrote:
>> At 11/13/2012 05:00 AM, Toshi Kani Wrote:
>>> On Thu, 2012-11-08 at 19:04 +0800, Wen Congyang wrote:
>>>> The memory device can be removed by 2 ways:
>>>> 1. send eject request by SCI
>>>> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
>>>>
>>>> This 2 events may happen at the same time, so we may touch
>>>> acpi_memory_device.res_list at the same time. This patch
>>>> introduce a lock to protect this list.
>>>
>>> Hi Wen,
>>>
>>> This race condition is not unique in memory hot-remove as the sysfs
>>> eject interface is created for all objects with _EJ0.  For CPU
>>> hot-remove, I addressed this race condition by making the notify handler
>>> to run the hot-remove operation on kacpi_hotplug_wq by calling
>>> acpi_os_hotplug_execute().  This serializes the hot-remove operations
>>> among the two events since the sysfs eject also runs on
>>> kacpi_hotplug_wq.  This way is much simpler and is easy to maintain,
>>> although it does not allow both operations to run simultaneously (which
>>> I do not think we need).  Can it be used for memory hot-remove as well?
>>
>> Good idea. I will update it.
> 
> Still waiting. :-)
> 
> But if you want that in v3.8, please repost ASAP.

I think I will send it today. It is in test now.

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
