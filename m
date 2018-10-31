Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED76D6B0310
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 04:47:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d7-v6so13176389pfj.6
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 01:47:22 -0700 (PDT)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id j5-v6si25413931plk.145.2018.10.31.01.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 01:47:21 -0700 (PDT)
Message-ID: <1540975637.10275.10.camel@mtkswgap22>
Subject: Re: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
From: Miles Chen <miles.chen@mediatek.com>
Date: Wed, 31 Oct 2018 16:47:17 +0800
In-Reply-To: <20181030081537.GV32673@dhcp22.suse.cz>
References: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
	 <20181029080708.GA32673@dhcp22.suse.cz>
	 <20181029081706.GC32673@dhcp22.suse.cz>
	 <1540862950.12374.40.camel@mtkswgap22>
	 <20181030060601.GR32673@dhcp22.suse.cz>
	 <1540882551.23278.12.camel@mtkswgap22>
	 <20181030081537.GV32673@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Tue, 2018-10-30 at 09:15 +0100, Michal Hocko wrote:
> On Tue 30-10-18 14:55:51, Miles Chen wrote:
> [...]
> > It's a real problem when using page_owner.
> > I found this issue recently: I'm not able to read page_owner information
> > during a overnight test. (error: read failed: Out of memory). I replace
> > kmalloc() with vmalloc() and it worked well.
> 
> Is this with trimming the allocation to a single page and doing shorter
> than requested reads?


I printed out the allocate count on my device the request count is <=
4096. So I tested this scenario by trimming the count to from 4096 to
1024 bytes and it works fine. 

count = count > 1024? 1024: count;

It tested it on both 32bit and 64bit kernel.
