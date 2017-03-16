Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7BB6B038E
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 13:48:13 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u108so9780414wrb.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 10:48:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si5446266wmu.159.2017.03.16.10.48.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 10:48:12 -0700 (PDT)
Date: Thu, 16 Mar 2017 18:48:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 00/13] mm: sub-section memory hotplug support
Message-ID: <20170316174805.GB13654@dhcp22.suse.cz>
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Toshi Kani <toshi.kani@hpe.com>, linux-nvdimm@lists.01.org, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Nicolai Stange <nicstange@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

Hi,
I didn't get to look through the patch series yet and I might not be
able before LSF/MM. How urgent is this? I am primarily asking because
the memory hotplug is really convoluted right now and putting more on
top doesn't really sound like the thing we really want. I have tried to
simplify the code [1] already but this is an early stage work so I do
not want to impose any burden on you. So I am wondering whether this
is something that needs to be merged very soon or it can wait for the
rework and hopefully end up being much simpler in the end as well.

What do you think?

[1] http://lkml.kernel.org/r/20170315091347.GA32626@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
