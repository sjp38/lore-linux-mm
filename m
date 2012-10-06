Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 476F26B005A
	for <linux-mm@kvack.org>; Sat,  6 Oct 2012 10:22:45 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3126780pbb.14
        for <linux-mm@kvack.org>; Sat, 06 Oct 2012 07:22:44 -0700 (PDT)
Message-ID: <50703EA0.1050700@gmail.com>
Date: Sat, 06 Oct 2012 22:22:24 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] acpi,memory-hotplug : implement framework for hot
 removing memory
References: <506C0AE8.40702@jp.fujitsu.com>
In-Reply-To: <506C0AE8.40702@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On 10/03/2012 05:52 PM, Yasuaki Ishimatsu wrote:
> We are trying to implement a physical memory hot removing function as
> following thread.
>
> https://lkml.org/lkml/2012/9/5/201
>
> But there is not enough review to merge into linux kernel.
>
> I think there are following blockades.
>   1. no physical memory hot removable system

Which kind of special machine support physical memory hot-remove now?

>   2. huge patch-set
>
> If you have a KVM system, we can get rid of 1st blockade. Because
> applying following patch, we can create memory hot removable system
> on KVM guest.
>
> http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html
>
> 2nd blockade is own problem. So we try to divide huge patch into
> a small patch in each function as follows: 
>
>  - bug fix
>  - acpi framework
>  - kernel core
>
> We had already sent bug fix patches.
> https://lkml.org/lkml/2012/9/27/39
> https://lkml.org/lkml/2012/10/2/83
>
> The patch-set implements a framework for hot removing memory.
>
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
>
> In the 1st case, acpi_memory_disable_device() will be called.
> In the 2nd case, acpi_memory_device_remove() will be called.
> acpi_memory_device_remove() will also be called when we unbind the
> memory device from the driver acpi_memhotplug.
>
> acpi_memory_disable_device() has already implemented a code which
> offlines memory and releases acpi_memory_info struct . But
> acpi_memory_device_remove() has not implemented it yet.
>
> So the patch prepares the framework for hot removing memory and
> adds the framework intoacpi_memory_device_remove(). And it prepares
> remove_memory(). But the function does nothing because we cannot
> support memory hot remove.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
