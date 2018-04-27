Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5476B0007
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 06:20:24 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a124so989805qkb.19
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 03:20:24 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p12-v6si332685qvl.241.2018.04.27.03.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 03:20:23 -0700 (PDT)
Date: Fri, 27 Apr 2018 06:20:16 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc fallback
 options
In-Reply-To: <20180427082555.GC17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804270609020.22622@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com> <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <1524694663.4100.21.camel@HansenPartnership.com> <alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com> <1524697697.4100.23.camel@HansenPartnership.com> <23266.8532.619051.784274@quad.stoffel.home>
 <alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com> <20180427005213-mutt-send-email-mst@kernel.org> <alpine.LRH.2.02.1804261829190.30599@file01.intranet.prod.int.rdu2.redhat.com> <20180427082555.GC17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, John Stoffel <john@stoffel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Michal@stoffel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>, Andrew@stoffel.org, David Rientjes <rientjes@google.com>, Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, edumazet@google.com



On Fri, 27 Apr 2018, Michal Hocko wrote:

> On Thu 26-04-18 18:52:05, Mikulas Patocka wrote:
> > 
> > 
> > On Fri, 27 Apr 2018, Michael S. Tsirkin wrote:
> [...]
> > >    But assuming it's important to control this kind of
> > >    fault injection to be controlled from
> > >    a dedicated menuconfig option, why not the rest of
> > >    faults?
> > 
> > The injected faults cause damage to the user, so there's no point to 
> > enable them by default. vmalloc fallback should not cause any damage 
> > (assuming that the code is correctly written).
> 
> But you want to find those bugs which would BUG_ON easier, so there is a
> risk of harm IIUC

Yes, I want to harm them, but I only want to harm the users using the 
debugging kernel. Testers should be "harmed" by crashes - so that the 
users of production kernels are harmed less.

If someone hits this, he should report it, use the kernel parameter to 
turn it off and continue with the testing.

> and this is not much different than other fault injecting paths.

Fault injections causes misbehavior even on completely bug-free code (for 
example, syscalls randomly returning -ENOMEM). This won't cause 
misbehavior on bug-free code.

Mikulas
