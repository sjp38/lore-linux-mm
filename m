Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6CA6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:58:08 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kq14so85432pab.22
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:58:07 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id c16si3231565pdk.131.2014.08.27.16.58.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 16:58:07 -0700 (PDT)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C805C3EE0F8
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 08:58:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id DDFCBAC0486
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 08:58:03 +0900 (JST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 813F31DB802C
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 08:58:03 +0900 (JST)
Message-ID: <53FE705F.1050505@jp.fujitsu.com>
Date: Thu, 28 Aug 2014 08:57:19 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memory-hotplug: rename zones_online_to to valid_zones
References: <1409124238-18635-1-git-send-email-zhenzhang.zhang@huawei.com> <53FDBDF0.5000200@huawei.com> <53FDBE6B.8070100@huawei.com>
In-Reply-To: <53FDBE6B.8070100@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Toshi Kani <toshi.kani@hp.com>
Cc: wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

(2014/08/27 20:18), Zhang Zhen wrote:
> Rename the interface to valid_zones according to most pepole's
> suggestion.
>
> Sample output of the sysfs files:
> 	memory0/valid_zones: none
> 	memory1/valid_zones: DMA32
> 	memory2/valid_zones: DMA32
> 	memory3/valid_zones: DMA32
> 	memory4/valid_zones: Normal
> 	memory5/valid_zones: Normal
> 	memory6/valid_zones: Normal Movable
> 	memory7/valid_zones: Movable Normal
> 	memory8/valid_zones: Movable
>
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

> ---
>   Documentation/ABI/testing/sysfs-devices-memory |  8 ++++----
>   Documentation/memory-hotplug.txt               | 13 ++++++++++---
>   drivers/base/memory.c                          |  6 +++---
>   3 files changed, 17 insertions(+), 10 deletions(-)
>
> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
> index 2b2a1d7..deef3b5 100644
> --- a/Documentation/ABI/testing/sysfs-devices-memory
> +++ b/Documentation/ABI/testing/sysfs-devices-memory
> @@ -61,13 +61,13 @@ Users:		hotplug memory remove tools
>   		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils
>
>
> -What:           /sys/devices/system/memory/memoryX/zones_online_to
> +What:           /sys/devices/system/memory/memoryX/valid_zones
>   Date:           July 2014
>   Contact:	Zhang Zhen <zhenzhang.zhang@huawei.com>
>   Description:
> -		The file /sys/devices/system/memory/memoryX/zones_online_to
> -		is read-only and is designed to show which zone this memory block can
> -		be onlined to.
> +		The file /sys/devices/system/memory/memoryX/valid_zones	is
> +		read-only and is designed to show which zone this memory
> +		block can be onlined to.
>
>   What:		/sys/devices/system/memoryX/nodeY
>   Date:		October 2009
> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
> index 5b34e33..93a25ef 100644
> --- a/Documentation/memory-hotplug.txt
> +++ b/Documentation/memory-hotplug.txt
> @@ -155,7 +155,7 @@ Under each memory block, you can see 4 files:
>   /sys/devices/system/memory/memoryXXX/phys_device
>   /sys/devices/system/memory/memoryXXX/state
>   /sys/devices/system/memory/memoryXXX/removable
> -/sys/devices/system/memory/memoryXXX/zones_online_to
> +/sys/devices/system/memory/memoryXXX/valid_zones
>
>   'phys_index'      : read-only and contains memory block id, same as XXX.
>   'state'           : read-write
> @@ -171,8 +171,15 @@ Under each memory block, you can see 4 files:
>                       block is removable and a value of 0 indicates that
>                       it is not removable. A memory block is removable only if
>                       every section in the block is removable.
> -'zones_online_to' : read-only: designed to show which zone this memory block
> -		    can be onlined to.
> +'valid_zones'     : read-only: designed to show which zones this memory block
> +		    can be onlined to.
> +		    The first column shows it's default zone.
> +		    "memory6/valid_zones: Normal Movable" shows this memoryblock
> +		    can be onlined to ZONE_NORMAL by default and to ZONE_MOVABLE
> +		    by online_movable.
> +		    "memory7/valid_zones: Movable Normal" shows this memoryblock
> +		    can be onlined to ZONE_MOVABLE by default and to ZONE_NORMAL
> +		    by online_kernel.
>
>   NOTE:
>     These directories/files appear after physical memory hotplug phase.
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 0fc1d25..efd456c 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -374,7 +374,7 @@ static ssize_t show_phys_device(struct device *dev,
>   }
>
>   #ifdef CONFIG_MEMORY_HOTREMOVE
> -static ssize_t show_zones_online_to(struct device *dev,
> +static ssize_t show_valid_zones(struct device *dev,
>   				struct device_attribute *attr, char *buf)
>   {
>   	struct memory_block *mem = to_memory_block(dev);
> @@ -409,7 +409,7 @@ static ssize_t show_zones_online_to(struct device *dev,
>
>   	return sprintf(buf, "%s\n", zone->name);
>   }
> -static DEVICE_ATTR(zones_online_to, 0444, show_zones_online_to, NULL);
> +static DEVICE_ATTR(valid_zones, 0444, show_valid_zones, NULL);
>   #endif
>
>   static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
> @@ -563,7 +563,7 @@ static struct attribute *memory_memblk_attrs[] = {
>   	&dev_attr_phys_device.attr,
>   	&dev_attr_removable.attr,
>   #ifdef CONFIG_MEMORY_HOTREMOVE
> -	&dev_attr_zones_online_to.attr,
> +	&dev_attr_valid_zones.attr,
>   #endif
>   	NULL
>   };
> -- 1.8.1.4
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
