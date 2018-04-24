Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E76796B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:33:02 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x2-v6so3535996qto.10
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:33:02 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s2si1792245qkc.138.2018.04.24.09.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 09:33:02 -0700 (PDT)
Date: Tue, 24 Apr 2018 12:33:01 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180424161242.GK17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804241229410.23702@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180420210200.GH10788@bombadil.infradead.org> <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com> <20180423151545.GU17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804232006540.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424133146.GG17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241107010.31601@file01.intranet.prod.int.rdu2.redhat.com> <20180424161242.GK17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Tue, 24 Apr 2018, Michal Hocko wrote:

> On Tue 24-04-18 11:30:40, Mikulas Patocka wrote:
> > 
> > 
> > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > 
> > > On Mon 23-04-18 20:25:15, Mikulas Patocka wrote:
> > > 
> > > > Fixing __vmalloc code 
> > > > is easy and it doesn't require cooperation with maintainers.
> > > 
> > > But it is a hack against the intention of the scope api.
> > 
> > It is not!
> 
> This discussion simply doesn't make much sense it seems. The scope API
> is to document the scope of the reclaim recursion critical section. That
> certainly is not a utility function like vmalloc.

That 15-line __vmalloc bugfix doesn't prevent you (or any other kernel 
developer) from converting the code to the scope API. You make nonsensical 
excuses.

Mikulas
