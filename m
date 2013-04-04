Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id A8EF66B0027
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 12:20:25 -0400 (EDT)
Date: Thu, 4 Apr 2013 18:20:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Message-ID: <20130404162023.GQ29911@dhcp22.suse.cz>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130404161746.GP29911@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130404161746.GP29911@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 04-04-13 18:17:46, Michal Hocko wrote:
> On Thu 04-04-13 17:09:08, Wanpeng Li wrote:
> > order >= MAX_ORDER pages are only allocated at boot stage using the 
> > bootmem allocator with the "hugepages=xxx" option. These pages are never 
> > free after boot by default since it would be a one-way street(>= MAX_ORDER
> > pages cannot be allocated later), but if administrator confirm not to 
> > use these gigantic pages any more, these pinned pages will waste memory
> > since other users can't grab free pages from gigantic hugetlb pool even
> > if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
> > shrink supporting. Administrator can enable knob exported in sysctl to
> > permit to shrink gigantic hugetlb pool.
> 
> I am not sure I see why the new knob is needed.
> /sys/kernel/mm/hugepages/hugepages-*/nr_hugepages is root interface so
> an additional step to allow writing to the file doesn't make much sense
> to me to be honest.
> 
> Support for shrinking gigantic huge pages makes some sense to me but I
> would be interested in the real world example. GB pages are usually used
> in very specific environments where the amount is usually well known.
> 
> I could imagine nr_hugepages_mempolicy would make more sense to free
> pages from particular nodes so they could be offlined for example.
> Does the patchset handles this as well?
 
Ohh, I should have checked before asking. Both knobs use the same
hugetlb_sysctl_handler_common and unless there is something hardcoded in
the patches then it should be supproted.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
