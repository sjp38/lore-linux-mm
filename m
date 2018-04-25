Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id A56556B0005
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 19:08:23 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id y49-v6so15964035oti.11
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 16:08:23 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id k26-v6si5958071oiw.278.2018.04.25.16.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Apr 2018 16:08:22 -0700 (PDT)
Message-ID: <1524697697.4100.23.camel@HansenPartnership.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 25 Apr 2018 16:08:17 -0700
In-Reply-To: <alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org>
	  <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
	  <20180423151545.GU17484@dhcp22.suse.cz>
	  <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
	 <20180424125121.GA17484@dhcp22.suse.cz>
	  <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com>
	  <20180424162906.GM17484@dhcp22.suse.cz>
	  <alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
	  <20180424170349.GQ17484@dhcp22.suse.cz>
	  <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
	  <20180424173836.GR17484@dhcp22.suse.cz>
	  <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
	  <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
	  <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
	  <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
	  <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
	 <1524694663.4100.21.camel@HansenPartnership.com>
	 <alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: David Rientjes <rientjes@google.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 2018-04-25 at 19:00 -0400, Mikulas Patocka wrote:
> 
> On Wed, 25 Apr 2018, James Bottomley wrote:
> 
> > > > Do we really need the new config option?A A This could just be
> > > > manuallyA  tunable via fault injection IIUC.
> > >A 
> > > We do, because we want to enable it in RHEL and Fedora debugging
> > > kernels,A so that it will be tested by the users.
> > >A 
> > > The users won't use some extra magic kernel options or debugfs
> files.
> >A 
> > If it can be enabled via a tunable, then the distro can turn it on
> > without the user having to do anything.A  If you want to present the
> > user with a different boot option, you can (just have the tunable
> set
> > on the command line), but being tunable driven means that you don't
> > have to choose that option, you could automatically enable it under
> a
> > range of circumstances.A  I think most sane distributions would want
> > that flexibility.
> >A 
> > Kconfig proliferation, conversely, is a bit of a nightmare from
> both
> > the user and the tester's point of view, so we're trying to avoid
> it
> > unless absolutely necessary.
> >A 
> > James
> 
> BTW. even developers who compile their own kernel should have this
> enabledA by a CONFIG option - because if the developer sees the option
> whenA browsing through menuconfig, he may enable it. If he doesn't see
> theA option, he won't even know that such an option exists.

I may be an atypical developer but I'd rather have a root canal than
browse through menuconfig options.  The way to get people to learn
about new debugging options is to blog about it (or write an lwn.net
article) which google will find the next time I ask it how I debug XXX.
 Google (probably as a service to humanity) rarely turns up Kconfig
options in response to a query.

James
