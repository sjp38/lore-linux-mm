Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 3AB806B003D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 13:39:39 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 11:39:38 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id CF31238C8070
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 13:39:28 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r38HdSO3305134
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 13:39:28 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r38HdStE007623
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 14:39:28 -0300
Message-ID: <516300C7.7000008@linux.vnet.ibm.com>
Date: Mon, 08 Apr 2013 10:39:19 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/page_alloc: factor out setting of pcp->high and
 pcp->batch.
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-2-git-send-email-cody@linux.vnet.ibm.com> <5160CDD8.3050908@gmail.com>
In-Reply-To: <5160CDD8.3050908@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/06/2013 06:37 PM, Simon Jeons wrote:
> Hi Cody,
> On 04/06/2013 04:33 AM, Cody P Schafer wrote:
>> Creates pageset_set_batch() for use in setup_pageset().
>> pageset_set_batch() imitates the functionality of
>> setup_pagelist_highmark(), but uses the boot time
>> (percpu_pagelist_fraction == 0) calculations for determining ->high
>
> Why need adjust pcp->high, pcp->batch during system running? What's the
> requirement?
>

There is currently a sysctl (which I patch later in this series) which 
allows adjusting the ->high mark (and, indirectly, ->batch). 
Additionally, memory hotplug changes ->high and ->batch due to the zone 
size changing (essentially, zone->managed_pages and zone->present_pages 
have changed) , meaning that zone_batchsize(), which is used at boot to 
set ->batch and (indirectly) ->high has a different output.

Note that in addition to the 2 users of this functionality mentioned 
here, I'm currently working on anther resizer of zones (runtime NUMA 
reconfiguration).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
