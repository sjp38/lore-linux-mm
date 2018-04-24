Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0241C6B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 20:25:22 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a125so12321228qkd.4
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 17:25:21 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n17si678138qvg.289.2018.04.23.17.25.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 17:25:20 -0700 (PDT)
Date: Mon, 23 Apr 2018 20:25:15 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180423151545.GU17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804232006540.2299@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net> <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com> <20180423151545.GU17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Mon, 23 Apr 2018, Michal Hocko wrote:

> On Mon 23-04-18 10:06:08, Mikulas Patocka wrote:
> 
> > > > He didn't want to fix vmalloc(GFP_NOIO)
> > > 
> > > I don't remember that conversation, so I don't know whether I agree with
> > > his reasoning or not.  But we are supposed to be moving away from GFP_NOIO
> > > towards marking regions with memalloc_noio_save() / restore.  If you do
> > > that, you won't need vmalloc(GFP_NOIO).
> > 
> > He said the same thing a year ago. And there was small progress. 6 out of 
> > 27 __vmalloc calls were converted to memalloc_noio_save in a year - 5 in 
> > infiniband and 1 in btrfs. (the whole discussion is here 
> > http://lkml.iu.edu/hypermail/linux/kernel/1706.3/04681.html )
> 
> Well this is not that easy. It requires a cooperation from maintainers.
> I can only do as much. I've posted patches in the past and actively
> bringing up this topic at LSFMM last two years...

You're right - but you have chosen the uneasy path. Fixing __vmalloc code 
is easy and it doesn't require cooperation with maintainers.

> > He refuses 15-line patch to fix GFP_NOIO bug because he believes that in 4 
> > years, the kernel will be refactored and GFP_NOIO will be eliminated. Why 
> > does he have veto over this part of the code? I'd much rather argue with 
> > people who have constructive comments about fixing bugs than with him.
> 
> I didn't NACK the patch AFAIR. I've said it is not a good idea longterm.
> I would be much more willing to change my mind if you would back your
> patch by a real bug report. Hacks are acceptable when we have a real
> issue in hands. But if we want to fix potential issue then better make
> it properly.

Developers should fix bugs in advance, not to wait until a crash hapens, 
is analyzed and reported.

What's the problem with 15-line hack? Is the problem that kernel 
developers would feel depressed when looking the source code? Other than 
harming developers' feelings, I don't see what kind of damange could that 
piece of code do.

Mikulas
