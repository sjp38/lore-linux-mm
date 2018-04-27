Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3CCD6B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 04:26:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k3so1035029pff.23
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 01:26:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x3-v6si806565plb.478.2018.04.27.01.26.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Apr 2018 01:26:00 -0700 (PDT)
Date: Fri, 27 Apr 2018 10:25:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
Message-ID: <20180427082555.GC17484@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <1524694663.4100.21.camel@HansenPartnership.com>
 <alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com>
 <1524697697.4100.23.camel@HansenPartnership.com>
 <23266.8532.619051.784274@quad.stoffel.home>
 <alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com>
 <20180427005213-mutt-send-email-mst@kernel.org>
 <alpine.LRH.2.02.1804261829190.30599@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804261829190.30599@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, John Stoffel <john@stoffel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Michal@stoffel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>, Andrew@stoffel.org, David Rientjes <rientjes@google.com>, Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, edumazet@google.com

On Thu 26-04-18 18:52:05, Mikulas Patocka wrote:
> 
> 
> On Fri, 27 Apr 2018, Michael S. Tsirkin wrote:
[...]
> >    But assuming it's important to control this kind of
> >    fault injection to be controlled from
> >    a dedicated menuconfig option, why not the rest of
> >    faults?
> 
> The injected faults cause damage to the user, so there's no point to 
> enable them by default. vmalloc fallback should not cause any damage 
> (assuming that the code is correctly written).

But you want to find those bugs which would BUG_ON easier, so there is a
risk of harm IIUC and this is not much different than other fault
injecting paths.
-- 
Michal Hocko
SUSE Labs
