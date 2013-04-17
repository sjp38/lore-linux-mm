Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 7C1936B0074
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 21:11:50 -0400 (EDT)
Date: Tue, 16 Apr 2013 18:11:44 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Message-ID: <20130417011144.GA20835@dhcp22.suse.cz>
References: <1366158995-3116-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1366158995-3116-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-04-13 08:36:28, Wanpeng Li wrote:
> Changelog:
>  * add comments from Andi which indicate shrink gigantic hugetlb page pools make 
>    sense to patchset description.
>
> order >= MAX_ORDER pages are only allocated at boot stage using the 
> bootmem allocator with the "hugepages=xxx" option. These pages are never 
> free after boot by default since it would be a one-way street(>= MAX_ORDER
> pages cannot be allocated later), but if administrator confirm not to 
> use these gigantic pages any more, these pinned pages will waste memory
> since other users can't grab free pages from gigantic hugetlb pool even
> if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
> shrink supporting. Administrator can enable knob exported in sysctl to
> permit to shrink gigantic hugetlb pool.
> 
> http://marc.info/?l=linux-mm&m=136578016214512&w=2 
> Andi thinks this idea make sense since he is working on a new patchkit to 
> allocate GB pages from CMA. With that freeing actually makes sense, as the 
> pages can be reallocated.

But that is not implemented yet...
 
> 
> Testcase:
> boot: hugepagesz=1G hugepages=10
> 
> [root@localhost hugepages]# free -m
>              total       used       free     shared    buffers     cached
> Mem:         36269      10836      25432          0         11        288
> -/+ buffers/cache:      10537      25732
> Swap:        35999          0      35999
> [root@localhost hugepages]# echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
> -bash: echo: write error: Invalid argument
> [root@localhost hugepages]# echo 1 > /proc/sys/vm/hugetlb_shrink_gigantic_pool

I have asked that already but it didn't get answered. What is the reason
for an explicit knob to enable this? It just adds an additional code and
it doesn't make much sense to me to be honest.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
