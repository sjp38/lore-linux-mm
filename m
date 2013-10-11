Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 37B046B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 12:35:01 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so4458626pbc.18
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 09:35:00 -0700 (PDT)
Message-ID: <1381509080.26234.32.camel@misato.fc.hp.com>
Subject: Re: [PATCH] Release device_hotplug_lock when store_mem_state
 returns EINVAL
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 11 Oct 2013 10:31:20 -0600
In-Reply-To: <52579C69.1080304@jp.fujitsu.com>
References: <52579C69.1080304@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org

On Fri, 2013-10-11 at 15:36 +0900, Yasuaki Ishimatsu wrote:
> When inserting a wrong value to /sys/devices/system/memory/memoryX/state file,
> following messages are shown. And device_hotplug_lock is never released.
> 
> ================================================
> [ BUG: lock held when returning to user space! ]
> 3.12.0-rc4-debug+ #3 Tainted: G        W
> ------------------------------------------------
> bash/6442 is leaving the kernel with locks still held!
> 1 lock held by bash/6442:
>  #0:  (device_hotplug_lock){+.+.+.}, at: [<ffffffff8146cbb5>] lock_device_hotplug_sysfs+0x15/0x50
> 
> This issue was introdued by commit fa2be40 (drivers: base: use standard
> device online/offline for state change).
> 
> This patch releases device_hotplug_lcok when store_mem_state returns EINVAL.
> 
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> CC: Toshi Kani <toshi.kani@hp.com>
> CC: Seth Jennings <sjenning@linux.vnet.ibm.com>
> CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Good catch!

Reviewed-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
