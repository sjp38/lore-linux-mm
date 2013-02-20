Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8ACB26B0022
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 17:49:19 -0500 (EST)
Date: Wed, 20 Feb 2013 14:49:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: let /proc/meminfo report physical memory
 installed as "MemTotal"
Message-Id: <20130220144917.7d289ef0.akpm@linux-foundation.org>
In-Reply-To: <1361381245-14664-1-git-send-email-jiang.liu@huawei.com>
References: <alpine.DEB.2.02.1302191326150.6322@chino.kir.corp.google.com>
	<1361381245-14664-1-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: David Rientjes <rientjes@google.com>, sworddragon2@aol.com, Jiang Liu <jiang.liu@huawei.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Thu, 21 Feb 2013 01:27:25 +0800
Jiang Liu <liuj97@gmail.com> wrote:

> As reported by https://bugzilla.kernel.org/show_bug.cgi?id=53501,
> "MemTotal" from /proc/meminfo means memory pages managed by the buddy
> system (managed_pages), but "MemTotal" from /sys/.../node/nodex/meminfo
> means phsical pages present (present_pages) within the NUMA node.
> There's a difference between managed_pages and present_pages due to
> bootmem allocator and reserved pages.
> 
> So change /proc/meminfo to report physical memory installed as
> "MemTotal", which is
> MemTotal = sum(pgdat->present_pages)

Documentation/filesystems/proc.txt says

    MemTotal: Total usable ram (i.e. physical ram minus a few reserved
              bits and the kernel binary code)

And arguably, that is more useful than "total physical memory".

Presumably the per-node MemTotals are including kernel memory and
reserved memory.  Maybe they should be fixed instead (sounds hard).

Or maybe we just leave everything as-is and document it carefully.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
