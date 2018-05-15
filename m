Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 426FC6B026D
	for <linux-mm@kvack.org>; Mon, 14 May 2018 21:13:16 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 89-v6so1106690plc.1
        for <linux-mm@kvack.org>; Mon, 14 May 2018 18:13:16 -0700 (PDT)
Received: from lgeamrelo11.lge.com (lgeamrelo13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e12-v6si8587289pgn.155.2018.05.14.18.13.13
        for <linux-mm@kvack.org>;
        Mon, 14 May 2018 18:13:14 -0700 (PDT)
Date: Tue, 15 May 2018 10:13:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG
Message-ID: <20180515011311.GA32447@js1304-desktop>
References: <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180421144757.GC14610@bombadil.infradead.org>
 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424034643.GA26636@bombadil.infradead.org>
 <alpine.LRH.2.02.1804240818530.28016@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424171651.GC30577@bombadil.infradead.org>
 <alpine.LRH.2.02.1804241428120.8296@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804241428120.8296@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

Hello, Mikulas.

On Tue, Apr 24, 2018 at 02:41:47PM -0400, Mikulas Patocka wrote:
> 
> 
> On Tue, 24 Apr 2018, Matthew Wilcox wrote:
> 
> > On Tue, Apr 24, 2018 at 08:29:14AM -0400, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Mon, 23 Apr 2018, Matthew Wilcox wrote:
> > > 
> > > > On Mon, Apr 23, 2018 at 08:06:16PM -0400, Mikulas Patocka wrote:
> > > > > Some bugs (such as buffer overflows) are better detected
> > > > > with kmalloc code, so we must test the kmalloc path too.
> > > > 
> > > > Well now, this brings up another item for the collective TODO list --
> > > > implement redzone checks for vmalloc.  Unless this is something already
> > > > taken care of by kasan or similar.
> > > 
> > > The kmalloc overflow testing is also not ideal - it rounds the size up to 
> > > the next slab size and detects buffer overflows only at this boundary.
> > > 
> > > Some times ago, I made a "kmalloc guard" patch that places a magic number 
> > > immediatelly after the requested size - so that it can detect overflows at 
> > > byte boundary 
> > > ( https://www.redhat.com/archives/dm-devel/2014-September/msg00018.html )
> > > 
> > > That patch found a bug in crypto code:
> > > ( http://lkml.iu.edu/hypermail/linux/kernel/1409.1/02325.html )
> > 
> > Is it still worth doing this, now we have kasan?
> 
> The kmalloc guard has much lower overhead than kasan.

I skimm at your code and it requires rebuilding the kernel.
I think that if rebuilding is required as the same with the KASAN,
using the KASAN is better since it has far better coverage for
detection the bug.

However, I think that if the redzone can be setup tightly
without rebuild, it would be worth implementing. I have an idea to
implement it only for the SLUB. Could I try it? (I'm asking this
because I'm inspired from the above patch.) :)
Or do you wanna try it?

Thanks.
