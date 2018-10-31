Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 827F16B02E8
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:19:51 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 3-v6so4746144plc.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 03:19:51 -0700 (PDT)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id w126-v6si18057353pfw.257.2018.10.31.03.19.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 03:19:50 -0700 (PDT)
Message-ID: <1540981182.16084.1.camel@mtkswgap22>
Subject: Re: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
From: Miles Chen <miles.chen@mediatek.com>
Date: Wed, 31 Oct 2018 18:19:42 +0800
In-Reply-To: <20181031101501.GL32673@dhcp22.suse.cz>
References: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
	 <20181029080708.GA32673@dhcp22.suse.cz>
	 <20181029081706.GC32673@dhcp22.suse.cz>
	 <1540862950.12374.40.camel@mtkswgap22>
	 <20181030060601.GR32673@dhcp22.suse.cz>
	 <1540882551.23278.12.camel@mtkswgap22>
	 <20181030081537.GV32673@dhcp22.suse.cz>
	 <1540975637.10275.10.camel@mtkswgap22>
	 <20181031101501.GL32673@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Wed, 2018-10-31 at 11:15 +0100, Michal Hocko wrote:
> On Wed 31-10-18 16:47:17, Miles Chen wrote:
> > On Tue, 2018-10-30 at 09:15 +0100, Michal Hocko wrote:
> > > On Tue 30-10-18 14:55:51, Miles Chen wrote:
> > > [...]
> > > > It's a real problem when using page_owner.
> > > > I found this issue recently: I'm not able to read page_owner information
> > > > during a overnight test. (error: read failed: Out of memory). I replace
> > > > kmalloc() with vmalloc() and it worked well.
> > > 
> > > Is this with trimming the allocation to a single page and doing shorter
> > > than requested reads?
> > 
> > 
> > I printed out the allocate count on my device the request count is <=
> > 4096. So I tested this scenario by trimming the count to from 4096 to
> > 1024 bytes and it works fine. 
> > 
> > count = count > 1024? 1024: count;
> > 
> > It tested it on both 32bit and 64bit kernel.
> 
> Are you saying that you see OOMs for 4k size?
> 
yes, because kmalloc only use normal memor, not highmem + normal memory
I think that's why vmalloc() works.
