Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4629A6B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 20:45:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g27so101691533pfj.6
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 17:45:36 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g4si5106352pln.186.2017.06.29.17.45.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 17:45:35 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id e199so14978893pfh.0
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 17:45:35 -0700 (PDT)
Date: Fri, 30 Jun 2017 09:45:24 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: display allowed zones in the
 preferred ordering
Message-ID: <20170630004522.GA13062@js1304-desktop>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170629073509.623-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Jun 29, 2017 at 09:35:08AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Prior to "mm, memory_hotplug: do not associate hotadded memory to zones
> until online" we used to allow to change the valid zone types of a
> memory block if it is adjacent to a different zone type. This fact was
> reflected in memoryNN/valid_zones by the ordering of printed zones.
> The first one was default (echo online > memoryNN/state) and the other
> one could be onlined explicitly by online_{movable,kernel}. This
> behavior was removed by the said patch and as such the ordering was
> not all that important. In most cases a kernel zone would be default
> anyway. The only exception is movable_node handled by "mm,
> memory_hotplug: support movable_node for hotpluggable nodes".
> 
> Let's reintroduce this behavior again because later patch will remove
> the zone overlap restriction and so user will be allowed to online
> kernel resp. movable block regardless of its placement. Original
> behavior will then become significant again because it would be
> non-trivial for users to see what is the default zone to online into.
> 
> Implementation is really simple. Pull out zone selection out of
> move_pfn_range into zone_for_pfn_range helper and use it in
> show_valid_zones to display the zone for default onlining and then
> both kernel and movable if they are allowed. Default online zone is not
> duplicated.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> 

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
