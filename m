Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59BFE6B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 08:55:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u96so15527920wrc.7
        for <linux-mm@kvack.org>; Wed, 24 May 2017 05:55:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si22577603edc.294.2017.05.24.05.55.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 05:55:02 -0700 (PDT)
Date: Wed, 24 May 2017 14:55:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, memory_hotplug: drop artificial restriction
 on online/offline
Message-ID: <20170524125500.GG14733@dhcp22.suse.cz>
References: <20170524122411.25212-1-mhocko@kernel.org>
 <20170524122411.25212-2-mhocko@kernel.org>
 <467b4bcb-cc7e-a001-b35c-29d0ce29efee@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <467b4bcb-cc7e-a001-b35c-29d0ce29efee@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 24-05-17 14:44:34, Vlastimil Babka wrote:
> On 05/24/2017 02:24 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > 74d42d8fe146 ("memory_hotplug: ensure every online node has NORMAL
> > memory") has added can_offline_normal which checks the amount of
> > memory in !movable zones as long as CONFIG_MOVABLE_NODE is disable.
> > It disallows to offline memory if there is nothing left with a
> > justification that "memory-management acts bad when we have nodes which
> > is online but don't have any normal memory".
> > 
> > 74d42d8fe146 ("memory_hotplug: ensure every online node has NORMAL
> > memory")
> 
> That's the same commit as above... one of them should be different?

This used to be two different patches which I decided to fold together
and I didn't realize that both online and offline paths were introduced
by the same patch.
[...]
> Some editing issue?

yes result of merging two commits.

> Otherwise makes sense to me.
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks! Updated version follows
---
