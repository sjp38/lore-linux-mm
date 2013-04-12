Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id C8E4D6B0006
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:22:39 -0400 (EDT)
Date: Fri, 12 Apr 2013 17:22:37 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Message-ID: <20130412152237.GM16732@two.firstfloor.org>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130411232907.GC29398@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411232907.GC29398@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 12, 2013 at 07:29:07AM +0800, Wanpeng Li wrote:
> Ping Andi,
> On Thu, Apr 04, 2013 at 05:09:08PM +0800, Wanpeng Li wrote:
> >order >= MAX_ORDER pages are only allocated at boot stage using the 
> >bootmem allocator with the "hugepages=xxx" option. These pages are never 
> >free after boot by default since it would be a one-way street(>= MAX_ORDER
> >pages cannot be allocated later), but if administrator confirm not to 
> >use these gigantic pages any more, these pinned pages will waste memory
> >since other users can't grab free pages from gigantic hugetlb pool even
> >if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
> >shrink supporting. Administrator can enable knob exported in sysctl to
> >permit to shrink gigantic hugetlb pool.


I originally didn't allow this because it's only one way and it seemed
dubious.  I've been recently working on a new patchkit to allocate
GB pages from CMA. With that freeing actually makes sense, as 
the pages can be reallocated.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
