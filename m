Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id F1637828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:35:31 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id a85so424770378ykb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:35:31 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i196si2066999ywc.244.2016.01.13.12.35.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 12:35:31 -0800 (PST)
Date: Wed, 13 Jan 2016 21:34:44 +0100
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCH v5 1/2] memory-hotplug: add automatic onlining policy for
 the newly added memory
Message-ID: <20160113203444.GY3485@olila.local.net-space.pl>
References: <1452706350-21158-1-git-send-email-vkuznets@redhat.com>
 <1452706350-21158-2-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452706350-21158-2-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On Wed, Jan 13, 2016 at 06:32:29PM +0100, Vitaly Kuznetsov wrote:
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
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
