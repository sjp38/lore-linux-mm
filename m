Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 1D0856B0085
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:53:01 -0400 (EDT)
Date: Fri, 5 Apr 2013 11:52:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Message-ID: <20130405095258.GC31132@dhcp22.suse.cz>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130404161746.GP29911@dhcp22.suse.cz>
 <20130404234123.GA362@hacker.(null)>
 <20130405081239.GC14882@dhcp22.suse.cz>
 <515E9154.6050709@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515E9154.6050709@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 05-04-13 16:54:44, Simon Jeons wrote:
> Hi Michal,
> On 04/05/2013 04:12 PM, Michal Hocko wrote:
> >On Fri 05-04-13 07:41:23, Wanpeng Li wrote:
> >>On Thu, Apr 04, 2013 at 06:17:46PM +0200, Michal Hocko wrote:
> >>>On Thu 04-04-13 17:09:08, Wanpeng Li wrote:
> >>>>order >= MAX_ORDER pages are only allocated at boot stage using the
> >>>>bootmem allocator with the "hugepages=xxx" option. These pages are never
> >>>>free after boot by default since it would be a one-way street(>= MAX_ORDER
> >>>>pages cannot be allocated later), but if administrator confirm not to
> >>>>use these gigantic pages any more, these pinned pages will waste memory
> >>>>since other users can't grab free pages from gigantic hugetlb pool even
> >>>>if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
> >>>>shrink supporting. Administrator can enable knob exported in sysctl to
> >>>>permit to shrink gigantic hugetlb pool.
> >>>I am not sure I see why the new knob is needed.
> >>>/sys/kernel/mm/hugepages/hugepages-*/nr_hugepages is root interface so
> >>>an additional step to allow writing to the file doesn't make much sense
> >>>to me to be honest.
> >>>
> >>>Support for shrinking gigantic huge pages makes some sense to me but I
> >>>would be interested in the real world example. GB pages are usually used
> >>>in very specific environments where the amount is usually well known.
> >>Gigantic huge pages in hugetlb means h->order >= MAX_ORDER instead of GB
> >>pages. ;-)
> >Yes, I am aware of that but the question remains the same (and
> >unanswered). What is the use case?
> 
> As patch description, "if administrator confirm not to use these
> gigantic pages any more, these pinned pages will waste memory since
> other users can't grab free pages from gigantic hugetlb pool even if
> OOM".

Is this a use case that we care about? How often something like that
happens? I understand this is "nice to have" but I am interested whether
somebody actually _needs_ this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
