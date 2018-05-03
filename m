Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44F136B0007
	for <linux-mm@kvack.org>; Thu,  3 May 2018 13:40:51 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c20so13854690qkm.13
        for <linux-mm@kvack.org>; Thu, 03 May 2018 10:40:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s43-v6si6136809qta.53.2018.05.03.10.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 10:40:50 -0700 (PDT)
Date: Thu, 3 May 2018 13:40:48 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc fallback
 options
In-Reply-To: <23273.48986.516559.317965@quad.stoffel.home>
Message-ID: <alpine.LRH.2.02.1805031333050.28479@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org> <20180424173836.GR17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com> <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
 <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com> <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com> <1524694663.4100.21.camel@HansenPartnership.com>
 <alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com> <1524697697.4100.23.camel@HansenPartnership.com> <23266.8532.619051.784274@quad.stoffel.home> <alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com>
 <23271.24580.695738.853532@quad.stoffel.home> <alpine.LRH.2.02.1804301622480.4454@file01.intranet.prod.int.rdu2.redhat.com> <23273.48986.516559.317965@quad.stoffel.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Andrew@stoffel.org, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Hocko <mhocko@kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Michal@stoffel.org, edumazet@google.com, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>



On Wed, 2 May 2018, John Stoffel wrote:

> You miss my point, which is that there's no explanation of what the
> difference is between SLAB and SLUB and which I should choose.  The
> same goes here.  If the KConfig option doesn't give useful info, it's
> useless.

So what, we could write explamantion of that option.

> >> Now I also think that Linus has the right idea to not just sprinkle 
> >> BUG_ONs into the code, just dump and oops and keep going if you can.  
> >> If it's a filesystem or a device, turn it read only so that people 
> >> notice right away.
> 
> Mikulas> This vmalloc fallback is similar to
> Mikulas> CONFIG_DEBUG_KOBJECT_RELEASE.  CONFIG_DEBUG_KOBJECT_RELEASE
> Mikulas> changes the behavior of kobject_put in order to cause
> Mikulas> deliberate crashes (that wouldn't happen otherwise) in
> Mikulas> drivers that misuse kobject_put. In the same sense, we want
> Mikulas> to cause deliberate crashes (that wouldn't happen otherwise)
> Mikulas> in drivers that misuse kvmalloc.
> 
> Mikulas> The crashes will only happen in debugging kernels, not in
> Mikulas> production kernels.
> 
> Says you.  What about people or distros that enable it
> unconditionally?  They're going to get all kinds of reports and then
> turn it off again.  Crashing the system isn't the answer here.  

I've made that kvmalloc bug too (in the function 
dm_integrity_free_journal_scatterlist). I'd much rather like if the kernel 
crashed (because then - I would fix the bug). The kernel didn't crash and 
the bug sneaked into the official linux tree, where may be causing random 
crashes for other users.

Mikulas
