Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 402B66B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 09:41:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c85so4660219pfb.12
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 06:41:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u9-v6si6114119plk.516.2018.04.20.06.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 06:41:40 -0700 (PDT)
Date: Fri, 20 Apr 2018 06:41:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180420134136.GD10788@bombadil.infradead.org>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com>
 <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com>
 <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420130852.GC16083@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420130852.GC16083@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Fri, Apr 20, 2018 at 03:08:52PM +0200, Michal Hocko wrote:
> > In order to detect these bugs reliably I submit this patch that changes
> > kvmalloc to always use vmalloc if CONFIG_DEBUG_VM is turned on.
> 
> No way. This is just wrong! First of all, you will explode most likely
> on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
> enabled quite often.

I think it'll still suit Mikulas' debugging needs if we always use
vmalloc for sizes above PAGE_SIZE?
