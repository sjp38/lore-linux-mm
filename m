Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 520406B002D
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 18:56:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l9-v6so18681563qtp.23
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 15:56:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l20-v6si3397237qtb.184.2018.04.25.15.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 15:56:50 -0700 (PDT)
Date: Wed, 25 Apr 2018 18:56:49 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc fallback
 options
In-Reply-To: <alpine.DEB.2.21.1804251546240.58229@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1804251853460.31135@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org>  <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>  <20180423151545.GU17484@dhcp22.suse.cz>  <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424170349.GQ17484@dhcp22.suse.cz>  <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>  <20180424173836.GR17484@dhcp22.suse.cz>  <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
 <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>  <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>  <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>  <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <1524694663.4100.21.camel@HansenPartnership.com> <alpine.LRH.2.02.1804251830540.25124@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.21.1804251546240.58229@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>



On Wed, 25 Apr 2018, David Rientjes wrote:

> On Wed, 25 Apr 2018, Mikulas Patocka wrote:
> 
> > You need to enable it on boot. Enabling it when the kernel starts to 
> > execute userspace code is already too late (because you would miss 
> > kvmalloc calls in the kernel boot path).
> 
> Is your motivation that since kvmalloc() never falls back to vmalloc() on 
> boot because fragmentation is not be an issue at boot that we should catch 
> bugs where it would matter if it had fallen back?  If we are worrying 
> about falling back to vmalloc before even initscripts have run I think we 
> have bigger problems.

The same driver can be compiled directly into the kernel or be loaded as a 
module. If the user (or the person preparing distro kernel) compiles the 
driver directly into the kernel, kvmalloc should be tested on that driver, 
because a different user or distribution can compile that driver as a 
module.

Mikulas
