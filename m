From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Date: Fri, 5 Apr 2013 16:27:59 +0800
Message-ID: <40197.5063876764$1365150530@news.gmane.org>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130404161746.GP29911@dhcp22.suse.cz>
 <20130404234123.GA362@hacker.(null)>
 <20130405081239.GC14882@dhcp22.suse.cz>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UO20n-0005OW-Qq
	for glkm-linux-mm-2@m.gmane.org; Fri, 05 Apr 2013 10:28:42 +0200
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 31FAC6B0036
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 04:28:14 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 18:20:59 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id AFF752BB0050
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 19:28:07 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r358EjVl42336440
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 19:14:46 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r358S6aG011094
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 19:28:06 +1100
Content-Disposition: inline
In-Reply-To: <20130405081239.GC14882@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Fri, Apr 05, 2013 at 10:12:39AM +0200, Michal Hocko wrote:
>On Fri 05-04-13 07:41:23, Wanpeng Li wrote:
>> On Thu, Apr 04, 2013 at 06:17:46PM +0200, Michal Hocko wrote:
>> >On Thu 04-04-13 17:09:08, Wanpeng Li wrote:
>> >> order >= MAX_ORDER pages are only allocated at boot stage using the 
>> >> bootmem allocator with the "hugepages=xxx" option. These pages are never 
>> >> free after boot by default since it would be a one-way street(>= MAX_ORDER
>> >> pages cannot be allocated later), but if administrator confirm not to 
>> >> use these gigantic pages any more, these pinned pages will waste memory
>> >> since other users can't grab free pages from gigantic hugetlb pool even
>> >> if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
>> >> shrink supporting. Administrator can enable knob exported in sysctl to
>> >> permit to shrink gigantic hugetlb pool.
>> >
>> >I am not sure I see why the new knob is needed.
>> >/sys/kernel/mm/hugepages/hugepages-*/nr_hugepages is root interface so
>> >an additional step to allow writing to the file doesn't make much sense
>> >to me to be honest.
>> >
>> >Support for shrinking gigantic huge pages makes some sense to me but I
>> >would be interested in the real world example. GB pages are usually used
>> >in very specific environments where the amount is usually well known.
>> 
>> Gigantic huge pages in hugetlb means h->order >= MAX_ORDER instead of GB 
>> pages. ;-)
>
>Yes, I am aware of that but the question remains the same (and
>unanswered). What is the use case?

The use case I can figure out is when memory pressure is serious and gigantic 
huge pages pools still pin large number of free pages. 

Regards,
Wanpeng Li 

>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
