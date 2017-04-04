Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 339506B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 03:34:18 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z109so27236416wrb.1
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 00:34:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u127si18570206wmf.107.2017.04.04.00.34.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 00:34:17 -0700 (PDT)
Date: Tue, 4 Apr 2017 09:34:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170404073412.GC15132@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170403115545.GK24661@dhcp22.suse.cz>
 <20170403195830.64libncet5l6vuvb@arbab-laptop>
 <20170403202337.GA12482@dhcp22.suse.cz>
 <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
 <20170404072329.GA15132@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404072329.GA15132@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue 04-04-17 09:23:29, Michal Hocko wrote:
> [Let's add Gary who as introduced this code c04fc586c1a48]

OK, so Gary's email doesn't exist anymore. Does anybody can comment on
this? I suspect this code is just-in-case... Mel?
 
> On Mon 03-04-17 15:42:13, Reza Arbab wrote:
[...]
> > Almost there. I'm seeing the memory in the correct node now, but the
> > /sys/devices/system/node/nodeX/memoryY links are not being created.
> > 
> > I think it's tripping up here, in register_mem_sect_under_node():
> > 
> > 		page_nid = get_nid_for_pfn(pfn);
> > 		if (page_nid < 0)
> > 			continue;
> 
> Huh, this code is confusing. How can we have a memblock spanning more
> nodes? If not then the loop over all sections in the memblock seem
> pointless as well.  Also why do we require page_initialized() in
> get_nid_for_pfn? The changelog doesn't explain that and there are no
> comments that would help either.
> 
> Gary, could you clarify this please?
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
