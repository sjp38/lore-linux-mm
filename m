Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC1886B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 10:22:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i77so10465277wmh.10
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:22:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s30si19886477eds.310.2017.06.01.07.22.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 07:22:33 -0700 (PDT)
Date: Thu, 1 Jun 2017 16:22:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memory_hotplug: support movable_node for
 hotplugable nodes
Message-ID: <20170601142227.GF9091@dhcp22.suse.cz>
References: <20170601122004.32732-1-mhocko@kernel.org>
 <820164f3-8bef-7761-0695-88db9e0ce7a7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <820164f3-8bef-7761-0695-88db9e0ce7a7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 01-06-17 16:11:55, Vlastimil Babka wrote:
> On 06/01/2017 02:20 PM, Michal Hocko wrote:
[...]
> > Strictly speaking the semantic is not identical with the boot time
> > initialization because find_zone_movable_pfns_for_nodes covers only the
> > hotplugable range as described by the BIOS/FW. From my experience this
> > is usually a full node though (except for Node0 which is special and
> > never goes away completely). If this turns out to be a problem in the
> > real life we can tweak the code to store hotplug flag into memblocks
> > but let's keep this simple now.
> 
> Simple should work, hopefully.
> - if memory is hotplugged, it's obviously hotplugable, so we don't have
> to rely on BIOS description.

Not sure I understand. We do not have any information about the hotplug
status at the time we do online.

> - there shouldn't be a reason to offline a non-removable (part of) node
> and online it back (which would move it from Normal to Movable after
> your patch?), right?

not really. If the memblock was inside a kernel zone it will stay there
with a new online operation because we check for that explicitly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
