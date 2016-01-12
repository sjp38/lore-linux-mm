Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id F2526828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 18:07:40 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 65so70054346pff.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 15:07:40 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id h68si39117034pfj.161.2016.01.12.15.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 15:07:40 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id n128so70050494pfn.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 15:07:40 -0800 (PST)
Date: Tue, 12 Jan 2016 15:07:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/2] memory-hotplug: don't BUG() in
 register_memory_resource()
In-Reply-To: <1451924251-4189-2-git-send-email-vkuznets@redhat.com>
Message-ID: <alpine.DEB.2.10.1601121507100.28831@chino.kir.corp.google.com>
References: <1451924251-4189-1-git-send-email-vkuznets@redhat.com> <1451924251-4189-2-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Sheng Yong <shengyong1@huawei.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>

On Mon, 4 Jan 2016, Vitaly Kuznetsov wrote:

> Out of memory condition is not a bug and while we can't add new memory in
> such case crashing the system seems wrong. Propagating the return value
> from register_memory_resource() requires interface change.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tang Chen <tangchen@cn.fujitsu.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> Cc: Sheng Yong <shengyong1@huawei.com>
> Cc: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Igor Mammedov <imammedo@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
