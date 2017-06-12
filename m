Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7F796B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 02:35:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 56so20849243wrx.5
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 23:35:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c84si6977560wmi.39.2017.06.11.23.35.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Jun 2017 23:35:47 -0700 (PDT)
Date: Mon, 12 Jun 2017 08:35:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170612063544.GB4145@dhcp22.suse.cz>
References: <20170608122318.31598-1-mhocko@kernel.org>
 <20170610143356.GA3457@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170610143356.GA3457@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Sat 10-06-17 22:33:56, Wei Yang wrote:
> On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >movable_node kernel parameter allows to make hotplugable NUMA
> >nodes to put all the hotplugable memory into movable zone which
> >allows more or less reliable memory hotremove.  At least this
> >is the case for the NUMA nodes present during the boot (see
> >find_zone_movable_pfns_for_nodes).
> >
> >This is not the case for the memory hotplug, though.
> >
> >	echo online > /sys/devices/system/memory/memoryXYZ/status
>                                                            ^^^
> 
> Hmm, one typo I think
> 
> s/status/state/

right! Thanks for spotting that. I guess Andrew can update the changelog
or should I resubmit?


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
