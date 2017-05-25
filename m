Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43F306B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:28:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 10so41014452wml.4
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:28:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c40si24269506edb.70.2017.05.24.23.28.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 23:28:10 -0700 (PDT)
Date: Thu, 25 May 2017 08:28:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, memory_hotplug: drop artificial restriction
 on online/offline
Message-ID: <20170525062808.GE12721@dhcp22.suse.cz>
References: <20170524122411.25212-1-mhocko@kernel.org>
 <20170524122411.25212-2-mhocko@kernel.org>
 <20170524215056.h4r3sdk23bn4c2sr@arbab-laptop.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524215056.h4r3sdk23bn4c2sr@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 24-05-17 16:50:56, Reza Arbab wrote:
> On Wed, May 24, 2017 at 02:24:10PM +0200, Michal Hocko wrote:
> >74d42d8fe146 ("memory_hotplug: ensure every online node has NORMAL
> >memory") has added can_offline_normal which checks the amount of
> >memory in !movable zones as long as CONFIG_MOVABLE_NODE is disable.
> >It disallows to offline memory if there is nothing left with a
> >justification that "memory-management acts bad when we have nodes which
> >is online but don't have any normal memory".
> >
> >74d42d8fe146 ("memory_hotplug: ensure every online node has NORMAL
> >memory") has introduced a restriction that every numa node has to have
> >at least some memory in !movable zones before a first movable memory
> >can be onlined if !CONFIG_MOVABLE_NODE with the same justification
> >
> >While it is true that not having _any_ memory for kernel allocations on
> >a NUMA node is far from great and such a node would be quite subotimal
> >because all kernel allocations will have to fallback to another NUMA
> >node but there is no reason to disallow such a configuration in
> >principle.
> >
> >Besides that there is not really a big difference to have one memblock
> >for ZONE_NORMAL available or none. With 128MB size memblocks the system
> >might trash on the kernel allocations requests anyway. It is really
> >hard to draw a line on how much normal memory is really sufficient so
> >we have to rely on administrator to configure system sanely therefore
> >drop the artificial restriction and remove can_offline_normal and
> >can_online_high_movable altogether.
> 
> I'm really liking all this cleanup of the memory hotplug code. Thanks!  Much
> appreciated.

I am glad to hear that and more is to come.

> Acked-by: Reza Arbab <arbab@linux.vnet.ibm.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
