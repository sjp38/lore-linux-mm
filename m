Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41D7D6B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 23:10:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n78so23778830pfj.4
        for <linux-mm@kvack.org>; Mon, 07 May 2018 20:10:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r5-v6si1355038pgv.244.2018.05.07.20.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 20:10:11 -0700 (PDT)
Date: Mon, 7 May 2018 20:09:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [External]  Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM
 (pmem) zone
Message-ID: <20180508030959.GB16338@bombadil.infradead.org>
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com>
 <20180507184622.GB12361@bombadil.infradead.org>
 <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
 <x49a7tbi8r3.fsf@segfault.boston.devel.redhat.com>
 <HK2PR03MB1684659175EB0A11E75E9B61929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR03MB1684659175EB0A11E75E9B61929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, NingTing Cheng <chengnt@lenovo.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, Linux MM <linux-mm@kvack.org>, "colyli@suse.de" <colyli@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@verizon.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

On Tue, May 08, 2018 at 02:59:40AM +0000, Huaisheng HS1 Ye wrote:
> Currently in our mind, an ideal use scenario is that, we put all page caches to
> zone_nvm, without any doubt, page cache is an efficient and common cache
> implement, but it has a disadvantage that all dirty data within it would has risk
> to be missed by power failure or system crash. If we put all page caches to NVDIMMs,
> all dirty data will be safe. 

That's a common misconception.  Some dirty data will still be in the
CPU caches.  Are you planning on building servers which have enough
capacitance to allow the CPU to flush all dirty data from LLC to NV-DIMM?

Then there's the problem of reconnecting the page cache (which is
pointed to by ephemeral data structures like inodes and dentries) to
the new inodes.

And then you have to convince customers that what you're doing is safe
enough for them to trust it ;-)
