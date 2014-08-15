Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 269F06B0036
	for <linux-mm@kvack.org>; Fri, 15 Aug 2014 17:47:39 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id t59so2725685yho.25
        for <linux-mm@kvack.org>; Fri, 15 Aug 2014 14:47:38 -0700 (PDT)
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com. [15.192.137.10])
        by mx.google.com with ESMTPS id y3si2731080yhy.14.2014.08.15.14.47.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 15 Aug 2014 14:47:38 -0700 (PDT)
Message-ID: <1408138647.26567.42.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] memory-hotplug: add sysfs zones_online_to attribute
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 15 Aug 2014 15:37:27 -0600
In-Reply-To: <53EAE534.8030303@huawei.com>
References: <1407902811-4873-1-git-send-email-zhenzhang.zhang@huawei.com>
	 <53EAE534.8030303@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, wangnan0@huawei.com, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Wed, 2014-08-13 at 12:10 +0800, Zhang Zhen wrote:
> Currently memory-hotplug has two limits:
> 1. If the memory block is in ZONE_NORMAL, you can change it to
> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
> 2. If the memory block is in ZONE_MOVABLE, you can change it to
> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
> 
> With this patch, we can easy to know a memory block can be onlined to
> which zone, and don't need to know the above two limits.
> 
> Updated the related Documentation.
> 
> Change v1 -> v2:
> - optimize the implementation following Dave Hansen's suggestion
> 
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
> ---
>  Documentation/ABI/testing/sysfs-devices-memory |  8 ++++
>  Documentation/memory-hotplug.txt               |  4 +-
>  drivers/base/memory.c                          | 62 ++++++++++++++++++++++++++
>  include/linux/memory_hotplug.h                 |  1 +
>  mm/memory_hotplug.c                            |  2 +-
>  5 files changed, 75 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
> index 7405de2..2b2a1d7 100644
> --- a/Documentation/ABI/testing/sysfs-devices-memory
> +++ b/Documentation/ABI/testing/sysfs-devices-memory
> @@ -61,6 +61,14 @@ Users:		hotplug memory remove tools
>  		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils
> 
> 
> +What:           /sys/devices/system/memory/memoryX/zones_online_to

I think this name is a bit confusing.  How about "valid_online_types"?

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
