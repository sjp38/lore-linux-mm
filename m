From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm/hugetlb: gigantic hugetlb page pools shrink
 supporting
Date: Mon, 15 Jul 2013 19:31:09 +0800
Message-ID: <41356.2888782055$1373887897@news.gmane.org>
References: <1365066554-29195-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130411232907.GC29398@hacker.(null)>
 <20130412152237.GM16732@two.firstfloor.org>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Uyh03-00023X-3J
	for glkm-linux-mm-2@m.gmane.org; Mon, 15 Jul 2013 13:31:27 +0200
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 458B46B00DD
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 07:31:22 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Jul 2013 16:55:46 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 53F2E1258053
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 17:00:33 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6FBV98J28311638
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 17:01:09 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6FBVB2q004860
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 21:31:12 +1000
Content-Disposition: inline
In-Reply-To: <20130412152237.GM16732@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andi,
On Fri, Apr 12, 2013 at 05:22:37PM +0200, Andi Kleen wrote:
>On Fri, Apr 12, 2013 at 07:29:07AM +0800, Wanpeng Li wrote:
>> Ping Andi,
>> On Thu, Apr 04, 2013 at 05:09:08PM +0800, Wanpeng Li wrote:
>> >order >= MAX_ORDER pages are only allocated at boot stage using the 
>> >bootmem allocator with the "hugepages=xxx" option. These pages are never 
>> >free after boot by default since it would be a one-way street(>= MAX_ORDER
>> >pages cannot be allocated later), but if administrator confirm not to 
>> >use these gigantic pages any more, these pinned pages will waste memory
>> >since other users can't grab free pages from gigantic hugetlb pool even
>> >if OOM, it's not flexible.  The patchset add hugetlb gigantic page pools
>> >shrink supporting. Administrator can enable knob exported in sysctl to
>> >permit to shrink gigantic hugetlb pool.
>
>
>I originally didn't allow this because it's only one way and it seemed
>dubious.  I've been recently working on a new patchkit to allocate
>GB pages from CMA. With that freeing actually makes sense, as 
>the pages can be reallocated.

How is your allocate hugetlb pages from CMA going on? If you don't have time
I will have a try. ;-)

Regards,
Wanpeng Li 

>
>-Andi
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
