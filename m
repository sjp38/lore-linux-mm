Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 159746B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 08:58:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t13so13138195pgu.23
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 05:58:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g2-v6si20633134plm.181.2018.04.26.05.58.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Apr 2018 05:58:22 -0700 (PDT)
Date: Thu, 26 Apr 2018 14:58:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
Message-ID: <20180426125817.GO17484@dhcp22.suse.cz>
References: <20180424170349.GQ17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424173836.GR17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
 <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
 <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <1524694663.4100.21.camel@HansenPartnership.com>
 <alpine.LRH.2.02.1804251830540.25124@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804251830540.25124@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, David Rientjes <rientjes@google.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

On Wed 25-04-18 18:42:57, Mikulas Patocka wrote:
> 
> 
> On Wed, 25 Apr 2018, James Bottomley wrote:
[...]
> > Kconfig proliferation, conversely, is a bit of a nightmare from both
> > the user and the tester's point of view, so we're trying to avoid it
> > unless absolutely necessary.
> > 
> > James
> 
> I already offered that we don't need to introduce a new kernel option and 
> we can bind this feature to any other kernel option, that is enabled in 
> the debug kernel, for example CONFIG_DEBUG_SG. Michal said no and he said 
> that he wants a new kernel option instead.

Just for the record. I didn't say I _want_ a config option. Do not
misinterpret my words. I've said that a config option would be
acceptable if there is no way to deliver the functionality via kernel
package automatically. You haven't provided any argument that would
explain why the kernel package cannot add a boot option. Maybe there are
some but I do not see them right now.
-- 
Michal Hocko
SUSE Labs
