Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E77F86B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 16:31:14 -0400 (EDT)
Received: by mail-ye0-f173.google.com with SMTP id g12so399708yee.4
        for <linux-mm@kvack.org>; Fri, 16 Aug 2013 13:31:13 -0700 (PDT)
Message-ID: <520E8C13.5020406@gmail.com>
Date: Fri, 16 Aug 2013 16:31:15 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hotplug: Remove stop_machine() from try_offline_node()
References: <1376336071-9128-1-git-send-email-toshi.kani@hp.com>  <520C2D04.8060408@gmail.com> <1376584540.10300.416.camel@misato.fc.hp.com>
In-Reply-To: <1376584540.10300.416.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, tangchen@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, liwanp@linux.vnet.ibm.com

>>> This patch removes the use of stop_machine() in try_offline_node() and
>>> adds comments to try_offline_node() and remove_memory() that
>>> lock_device_hotplug() is required.
>>
>> This patch need more verbose explanation. check_cpu_on_node() traverse cpus
>> and cpu hotplug seems to use cpu_hotplug_driver_lock() instead of lock_device_hotplug().
>
> As described:
>
> | lock_device_hotplug() serializes hotplug & online/offline operations.
> | The lock is held in common sysfs online/offline interfaces and ACPI
> | hotplug code paths.
>
> And here are their code paths.
>
> - CPU & Mem online/offline via sysfs online
> 	store_online()->lock_device_hotplug()
>
> - Mem online via sysfs state:
> 	store_mem_state()->lock_device_hotplug()
>
> - ACPI CPU & Mem hot-add:
> 	acpi_scan_bus_device_check()->lock_device_hotplug()
>
> - ACPI CPU & Mem hot-delete:
> 	acpi_scan_hot_remove()->lock_device_hotplug()

O.K.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
