Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 269D46B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 09:50:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x184so38504726wmf.14
        for <linux-mm@kvack.org>; Wed, 24 May 2017 06:50:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si25250111edj.227.2017.05.24.06.50.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 06:50:24 -0700 (PDT)
Date: Wed, 24 May 2017 15:50:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, memory_hotplug: drop CONFIG_MOVABLE_NODE
Message-ID: <20170524135020.GI14733@dhcp22.suse.cz>
References: <20170524122411.25212-1-mhocko@kernel.org>
 <20170524122411.25212-3-mhocko@kernel.org>
 <20170524153017.7a66368d@nial.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524153017.7a66368d@nial.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 24-05-17 15:30:17, Igor Mammedov wrote:
> On Wed, 24 May 2017 14:24:11 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> [...]
> > index facc20a3f962..ec7d6ae01c96 100644
> > --- a/Documentation/admin-guide/kernel-parameters.txt
> > +++ b/Documentation/admin-guide/kernel-parameters.txt
> > @@ -2246,8 +2246,11 @@
> [...]
> > +			movable. This means that the memory of such nodes
> > +			will be usable only for movable allocations which
> > +			rules out almost all kernel allocations. Use with
> > +			caution!
> maybe dumb question but, is it really true that kernel won't ever
> do kernel allocations from movable zone?
> 
> looking at kmalloc(slab): we can get here:
> 
> get_page_from_freelist() ->
>     rmqueue() ->
>         __rmqueue() ->
>             __rmqueue_fallback() ->
>                 find_suitable_fallback()
> 
> and it might return movable fallback and page could be stolen from there.

No, you are mixing movable/unmovable pageblocks and movable zones.
Movable zone basically works the same way as the Highmem zone. Have a
look at gfp_zone() and high_zoneidx usage in get_page_from_freelist
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
