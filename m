Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A49D36B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 22:28:07 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id n186so53024813wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 19:28:07 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id iq7si6681021wjb.143.2015.12.15.19.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Dec 2015 19:28:06 -0800 (PST)
Message-ID: <5670D83E.9040407@huawei.com>
Date: Wed, 16 Dec 2015 11:19:26 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] memory-hotplug: add automatic onlining policy for
 the newly added memory
References: <1450202753-5556-1-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1450202753-5556-1-git-send-email-vkuznets@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David
 Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y.
 Srinivasan" <kys@microsoft.com>, yanxiaofeng <yanxiaofeng@inspur.com>, Changsheng Liu <liuchangsheng@inspur.com>

On 2015/12/16 2:05, Vitaly Kuznetsov wrote:

> Currently, all newly added memory blocks remain in 'offline' state unless
> someone onlines them, some linux distributions carry special udev rules
> like:
> 
> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"
> 
> to make this happen automatically. This is not a great solution for virtual
> machines where memory hotplug is being used to address high memory pressure
> situations as such onlining is slow and a userspace process doing this
> (udev) has a chance of being killed by the OOM killer as it will probably
> require to allocate some memory.
> 
> Introduce default policy for the newly added memory blocks in
> /sys/devices/system/memory/hotplug_autoonline file with two possible
> values: "offline" (the default) which preserves the current behavior and
> "online" which causes all newly added memory blocks to go online as
> soon as they're added.
> 
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Daniel Kiper <daniel.kiper@oracle.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Tang Chen <tangchen@cn.fujitsu.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "K. Y. Srinivasan" <kys@microsoft.com>
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> ---
> - I was able to find previous attempts to fix the issue, e.g.:
>   http://marc.info/?l=linux-kernel&m=137425951924598&w=2
>   http://marc.info/?l=linux-acpi&m=127186488905382
>   but I'm not completely sure why it didn't work out and the solution
>   I suggest is not 'smart enough', thus 'RFC'.

+ CC: 
yanxiaofeng@inspur.com
liuchangsheng@inspur.com

Hi Vitaly,

Why not use udev rule? I think it can online pages automatically.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
