Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 990FA6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 09:49:06 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o16-v6so6180646wri.8
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 06:49:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f16si1339942ede.164.2018.04.20.06.49.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 06:49:05 -0700 (PDT)
Date: Fri, 20 Apr 2018 15:49:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180420134901.GB17484@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com>
 <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com>
 <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420130852.GC16083@dhcp22.suse.cz>
 <20180420134136.GD10788@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420134136.GD10788@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Fri 20-04-18 06:41:36, Matthew Wilcox wrote:
> On Fri, Apr 20, 2018 at 03:08:52PM +0200, Michal Hocko wrote:
> > > In order to detect these bugs reliably I submit this patch that changes
> > > kvmalloc to always use vmalloc if CONFIG_DEBUG_VM is turned on.
> > 
> > No way. This is just wrong! First of all, you will explode most likely
> > on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
> > enabled quite often.
> 
> I think it'll still suit Mikulas' debugging needs if we always use
> vmalloc for sizes above PAGE_SIZE?

Even if that was the case then this doesn't sounds like CONFIG_DEBUG_VM
material. We do not want a completely different behavior when the config
is enabled. If we really need some better fallback testing coverage
then the fault injection, as suggested by Vlastimil, sounds much more
reasonable to me

-- 
Michal Hocko
SUSE Labs
