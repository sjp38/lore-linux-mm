Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id A22556B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 16:25:59 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id t65so6910490yba.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:25:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s125si849576ybf.216.2016.08.31.13.25.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 13:25:59 -0700 (PDT)
Date: Wed, 31 Aug 2016 13:25:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH v2] memory-hotplug: fix store_mem_state() return
 value
Message-Id: <20160831132557.c5cf0985e3da5f2850a10b1d@linux-foundation.org>
In-Reply-To: <1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <20160831150105.GB26702@kroah.com>
	<1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 31 Aug 2016 10:44:01 -0500 Reza Arbab <arbab@linux.vnet.ibm.com> wrote:

> Attempting to online memory which is already online will cause this:
> 
> 1. store_mem_state() called with buf="online"
> 2. device_online() returns 1 because device is already online
> 3. store_mem_state() returns 1
> 4. calling code interprets this as 1-byte buffer read
> 5. store_mem_state() called again with buf="nline"
> 6. store_mem_state() returns -EINVAL
> 
> Example:
> 
> $ cat /sys/devices/system/memory/memory0/state
> online
> $ echo online > /sys/devices/system/memory/memory0/state
> -bash: echo: write error: Invalid argument
> 
> Fix the return value of store_mem_state() so this doesn't happen.

So..  what *does* happen after the patch?  Is some sort of failure still
reported?  Or am I correct in believing that the operation will appear
to have succeeded?  If so, is that desirable?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
