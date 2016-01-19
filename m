Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A3F596B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:44:09 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id uo6so445021704pac.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:44:09 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id da6si12073452pad.156.2016.01.19.14.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 14:44:08 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id n128so182630253pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:44:08 -0800 (PST)
Date: Tue, 19 Jan 2016 14:44:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v6 1/2] memory-hotplug: add automatic onlining policy
 for the newly added memory
In-Reply-To: <1452864645-27778-2-git-send-email-vkuznets@redhat.com>
Message-ID: <alpine.DEB.2.10.1601191443390.7346@chino.kir.corp.google.com>
References: <1452864645-27778-1-git-send-email-vkuznets@redhat.com> <1452864645-27778-2-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On Fri, 15 Jan 2016, Vitaly Kuznetsov wrote:

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
> /sys/devices/system/memory/auto_online_blocks file with two possible
> values: "offline" which preserves the current behavior and "online" which
> causes all newly added memory blocks to go online as soon as they're added.
> The default is "offline".
> 
> Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for the very good documentation!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
