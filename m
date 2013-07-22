Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id AF1D76B003B
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 04:37:26 -0400 (EDT)
Received: by mail-ea0-f180.google.com with SMTP id k10so3672500eaj.39
        for <linux-mm@kvack.org>; Mon, 22 Jul 2013 01:37:24 -0700 (PDT)
Date: Mon, 22 Jul 2013 10:37:22 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
Message-ID: <20130722083721.GC25976@gmail.com>
References: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374256068-26016-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, dave@sr71.net, kosaki.motohiro@gmail.com, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> CONFIG_ARCH_MEMORY_PROBE enables /sys/devices/system/memory/probe
> interface, which allows a given memory address to be hot-added as
> follows. (See Documentation/memory-hotplug.txt for more detail.)
> 
> # echo start_address_of_new_memory > /sys/devices/system/memory/probe
> 
> This probe interface is required on powerpc. On x86, however, ACPI
> notifies a memory hotplug event to the kernel, which performs its
> hotplug operation as the result. Therefore, regular users do not need
> this interface on x86. This probe interface is also error-prone and
> misleading that the kernel blindly adds a given memory address without
> checking if the memory is present on the system; no probing is done
> despite of its name. The kernel crashes when a user requests to online
> a memory block that is not present on the system. This interface is
> currently used for testing as it can fake a hotplug event.
> 
> This patch disables CONFIG_ARCH_MEMORY_PROBE by default on x86, adds
> its Kconfig menu entry on x86, and clarifies its use in Documentation/
> memory-hotplug.txt.

Could we please also fix it to never crash the kernel, even if stupid 
ranges are provided?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
