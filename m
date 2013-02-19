Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 86B886B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 16:29:55 -0500 (EST)
Received: by mail-da0-f51.google.com with SMTP id n15so3154034dad.24
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 13:29:54 -0800 (PST)
Date: Tue, 19 Feb 2013 13:29:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] vm: add 'MemManaged' field to /proc/meminfo and
 /sys/.../nodex/meminfo
In-Reply-To: <1361032046-1725-1-git-send-email-jiang.liu@huawei.com>
Message-ID: <alpine.DEB.2.02.1302191326150.6322@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com> <1361032046-1725-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com, Jiang Liu <jiang.liu@huawei.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Sun, 17 Feb 2013, Jiang Liu wrote:

> As reported by https://bugzilla.kernel.org/show_bug.cgi?id=53501,
> "MemTotal" from /proc/meminfo means memory pages managed by the buddy
> system (managed_pages), but "MemTotal" from /sys/.../node/nodex/meminfo
> means phsical pages present (present_pages) within the NUMA node.
> There's a difference between managed_pages and present_pages due to
> bootmem allocator and reserved pages.
> 
> So introduce a new field "MemManaged" to /sys/.../nodex/meminfo and
> /proc/meminfo, so that:
> MemTotal = present_pages
> MemManaged = managed_pages = present_pages - reserved_pages
> 

Nobody is asking for a MemManaged field, we're asking for consistency in 
MemTotal as exported by /proc/meminfo and 
/sys/devices/system/node/node*/meminfo.  In my opinion, this should be the 
amount of RAM installed on the system regardless of the amount of memory 
reserved, i.e. the current /sys/devices/system/node/node*/meminfo 
semantics.  There is no implicit guarantee that memory in MemTotal can be 
allocated by the buddy allocator.

So how about we just make the MemTotal in /proc/meminfo coincide with 
these semantics?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
