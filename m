Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9175C6B017F
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 18:22:35 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so270595pbb.7
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:22:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id wv10si39487732pbc.39.2014.06.11.15.22.34
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 15:22:34 -0700 (PDT)
Message-ID: <5398D691.7050202@intel.com>
Date: Wed, 11 Jun 2014 15:22:09 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, hotplug: probe interface is available on several
 platforms
References: <53981D81.5060708@huawei.com> <alpine.DEB.2.02.1406111503050.27885@chino.kir.corp.google.com> <alpine.DEB.2.02.1406111511450.27885@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406111511450.27885@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Zhang Zhen <zhenzhang.zhang@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, laijs@cn.fujitsu.com, sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>

On 06/11/2014 03:15 PM, David Rientjes wrote:
> +CONFIG_ARCH_MEMORY_PROBE and can be configured on powerpc, sh, and x86
> +if hotplug is supported, although for x86 this should be handled by ACPI
> +notification.

Looks like a good change, in general.

My only nit is that this implies that all hotplug on x86 is ACPI-based,
which isn't true.  Xen, at least, has an extension to its ballooning
that does hotplugs without ACPI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
