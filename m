Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 545CC6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 01:42:56 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id un3so2402671obb.11
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 22:42:55 -0700 (PDT)
Message-ID: <5163AA5A.9010205@gmail.com>
Date: Tue, 09 Apr 2013 13:42:50 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/page_alloc: factor out setting of pcp->high and
 pcp->batch.
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-2-git-send-email-cody@linux.vnet.ibm.com> <5160CDD8.3050908@gmail.com> <516300C7.7000008@linux.vnet.ibm.com>
In-Reply-To: <516300C7.7000008@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Cody,
On 04/09/2013 01:39 AM, Cody P Schafer wrote:
> On 04/06/2013 06:37 PM, Simon Jeons wrote:
>> Hi Cody,
>> On 04/06/2013 04:33 AM, Cody P Schafer wrote:
>>> Creates pageset_set_batch() for use in setup_pageset().
>>> pageset_set_batch() imitates the functionality of
>>> setup_pagelist_highmark(), but uses the boot time
>>> (percpu_pagelist_fraction == 0) calculations for determining ->high
>>
>> Why need adjust pcp->high, pcp->batch during system running? What's the
>> requirement?
>>
>
> There is currently a sysctl (which I patch later in this series) which 
> allows adjusting the ->high mark (and, indirectly, ->batch). 
> Additionally, memory hotplug changes ->high and ->batch due to the 
> zone size changing (essentially, zone->managed_pages and 
> zone->present_pages have changed) , meaning that zone_batchsize(), 
> which is used at boot to set ->batch and (indirectly) ->high has a 
> different output.

Thanks for your explain. I'm curious about this sysctl, when need adjust 
the ->high, ->batch during system running except memory hotplug which 
will change zone size?

>
> Note that in addition to the 2 users of this functionality mentioned 
> here, I'm currently working on anther resizer of zones (runtime NUMA 
> reconfiguration).
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
