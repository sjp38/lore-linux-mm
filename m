Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB216B0038
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 11:43:06 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w96so2282303wrb.13
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 08:43:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si24878789wmd.77.2017.04.05.08.43.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 08:43:04 -0700 (PDT)
Date: Wed, 5 Apr 2017 17:42:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170405154258.GR6035@dhcp22.suse.cz>
References: <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
 <20170405064239.GB6035@dhcp22.suse.cz>
 <20170405092427.GG6035@dhcp22.suse.cz>
 <20170405145304.wxzfavqxnyqtrlru@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405145304.wxzfavqxnyqtrlru@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed 05-04-17 09:53:05, Reza Arbab wrote:
[...]
> I hope this made sense. :/

yes it certainly helped me to make some picture of your setup. I will
keep thinking about that. But one thing that is really bugging me is
how could you see low pfns in the previous oops. Please drop the last
patch and sprinkle printks down the remove_memory path to see where this
all go south. I believe that there is something in the initialization
code lurking in my code. Please also scratch the pfn_valid check in
online_pages diff. It will not help here.

I suspect I broke some hidden expectation that made add_memory vs.
remove_memory more symetric before. I will keep digging.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
