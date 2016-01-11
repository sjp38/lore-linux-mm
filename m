Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9401F828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 06:01:23 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id v14so333020898ykd.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 03:01:23 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id s131si74332275ywb.140.2016.01.11.03.01.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 03:01:22 -0800 (PST)
Message-ID: <56938B7E.3060902@citrix.com>
Date: Mon, 11 Jan 2016 11:01:18 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] memory-hotplug: add automatic onlining policy for
 the newly added memory
References: <1452187421-15747-1-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1452187421-15747-1-git-send-email-vkuznets@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Jonathan
 Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David
 Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris
 Ostrovsky <boris.ostrovsky@oracle.com>

On 07/01/16 17:23, Vitaly Kuznetsov wrote:
> 
> - Changes since 'v1':
>   Add 'online' parameter to add_memory_resource() as it is being used by
>   xen ballon driver and it adds "empty" memory pages [David Vrabel].
>   (I don't completely understand what prevents manual onlining in this
>    case as we still have all newly added blocks in sysfs ... this is the
>    discussion point.)

I'm not sure what you're not understanding here?

Memory added by the Xen balloon driver (whether populated with real
memory or not) does need to be onlined by udev or similar.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
