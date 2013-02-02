Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 41BAA6B0007
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 19:39:26 -0500 (EST)
Date: Fri, 1 Feb 2013 16:39:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/9] mm: zone & pgdat accessors plus some cleanup
Message-Id: <20130201163924.75edfe40.akpm@linux-foundation.org>
In-Reply-To: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Jiang Liu <liuj97@gmail.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wu Jianguo <wujianguo@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Thu, 17 Jan 2013 14:52:52 -0800
Cody P Schafer <cody@linux.vnet.ibm.com> wrote:

> Summaries:
> 1 - avoid repeating checks for section in page flags by adding a define.
> 2 - add & switch to zone_end_pfn() and zone_spans_pfn()
> 3 - adds zone_is_initialized() & zone_is_empty()
> 4 - adds a VM_BUG using zone_is_initialized() in __free_one_page()
> 5 - add pgdat_end_pfn() and pgdat_is_empty()
> 6 - add debugging message to VM_BUG check.
> 7 - add ensure_zone_is_initialized() (for memory_hotplug)
> 8 - use the above addition in memory_hotplug
> 9 - use pgdat_end_pfn()

Well that's a nice little patchset.

Some of the patches were marked From:cody@linux.vnet.ibm.com and others
were From:jmesmon@gmail.com.  This is strange.  If you want me to fix
that up, please let me know which is preferred.

> As a general concern: spanned_pages & start_pfn (in pgdat & zone) are supposed
> to be locked (via a seqlock) when read (due to changes to them via
> memory_hotplug), but very few (only 1?) of their users appear to actually lock
> them.

OK, thanks.  Perhaps this is something which the memory-hotplug
developers could take a look at?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
