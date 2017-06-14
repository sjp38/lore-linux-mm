Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 623C16B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 05:08:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y19so12807040wrc.8
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:08:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m127si3749698wmg.165.2017.06.14.02.08.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 02:08:12 -0700 (PDT)
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
References: <20170608122318.31598-1-mhocko@kernel.org>
 <20170612042832.GA7429@WeideMBP.lan> <20170612064502.GD4145@dhcp22.suse.cz>
 <20170614090651.GA15288@WeideMacBook-Pro.local>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3e0a47c9-d51d-3d73-e876-abc1c5c81080@suse.cz>
Date: Wed, 14 Jun 2017 11:07:31 +0200
MIME-Version: 1.0
In-Reply-To: <20170614090651.GA15288@WeideMacBook-Pro.local>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 06/14/2017 11:06 AM, Wei Yang wrote:
> On Mon, Jun 12, 2017 at 08:45:02AM +0200, Michal Hocko wrote:
>> On Mon 12-06-17 12:28:32, Wei Yang wrote:
>>> On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
>>>> From: Michal Hocko <mhocko@suse.com>
>>>>
>>>> movable_node kernel parameter allows to make hotplugable NUMA
>>>> nodes to put all the hotplugable memory into movable zone which
>>>> allows more or less reliable memory hotremove.  At least this
>>>> is the case for the NUMA nodes present during the boot (see
>>>> find_zone_movable_pfns_for_nodes).
>>>>
>>>
>>> When movable_node is enabled, we would have overlapped zones, right?
>>
>> It won't based on this patch. See movable_pfn_range
> 
> I did grep in source code, but not find movable_pfn_range.

This patch is adding it.

> Could you share some light on that?
> 
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
