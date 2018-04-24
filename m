Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 751F56B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:12:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l26so523763wmc.4
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:12:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9si3581489edm.148.2018.04.24.09.12.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 09:12:47 -0700 (PDT)
Date: Tue, 24 Apr 2018 10:12:42 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180424161242.GK17484@dhcp22.suse.cz>
References: <20180420130852.GC16083@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180421144757.GC14610@bombadil.infradead.org>
 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804232006540.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424133146.GG17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241107010.31601@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804241107010.31601@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Tue 24-04-18 11:30:40, Mikulas Patocka wrote:
> 
> 
> On Tue, 24 Apr 2018, Michal Hocko wrote:
> 
> > On Mon 23-04-18 20:25:15, Mikulas Patocka wrote:
> > 
> > > Fixing __vmalloc code 
> > > is easy and it doesn't require cooperation with maintainers.
> > 
> > But it is a hack against the intention of the scope api.
> 
> It is not!

This discussion simply doesn't make much sense it seems. The scope API
is to document the scope of the reclaim recursion critical section. That
certainly is not a utility function like vmalloc.
-- 
Michal Hocko
SUSE Labs
