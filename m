Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF946B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:45:37 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 36-v6so4660215oth.17
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:45:37 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id p186-v6si6380165oif.398.2018.04.26.07.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Apr 2018 07:45:36 -0700 (PDT)
Message-ID: <1524753932.3226.5.camel@HansenPartnership.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 26 Apr 2018 07:45:32 -0700
In-Reply-To: <alpine.LRH.2.02.1804261006120.32722@file01.intranet.prod.int.rdu2.redhat.com>
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
	 <20180426125817.GO17484@dhcp22.suse.cz>
	 <alpine.LRH.2.02.1804261006120.32722@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

On Thu, 2018-04-26 at 10:28 -0400, Mikulas Patocka wrote:
> 
> On Thu, 26 Apr 2018, Michal Hocko wrote:
> 
> > On Wed 25-04-18 18:42:57, Mikulas Patocka wrote:
> > >A 
> > >A 
> > > On Wed, 25 Apr 2018, James Bottomley wrote:
> > [...]
> > > > Kconfig proliferation, conversely, is a bit of a nightmare from
> both
> > > > the user and the tester's point of view, so we're trying to
> avoid it
> > > > unless absolutely necessary.
> > > >A 
> > > > James
> > >A 
> > > I already offered that we don't need to introduce a new kernel
> option andA 
> > > we can bind this feature to any other kernel option, that is
> enabled inA 
> > > the debug kernel, for example CONFIG_DEBUG_SG. Michal said no and
> he saidA 
> > > that he wants a new kernel option instead.
> >A 
> > Just for the record. I didn't say I _want_ a config option. Do not
> > misinterpret my words. I've said that a config option would be
> > acceptable if there is no way to deliver the functionality via
> kernel
> > package automatically. You haven't provided any argument that would
> > explain why the kernel package cannot add a boot option. Maybe
> there are
> > some but I do not see them right now.
> 
> AFAIK Grub doesn't load per-kernel options from a per-kernel file.
> Even ifA we hacked grub scripts to add this option, other
> distributions won't.

Perhaps find out beforehand instead of insisting on an approach without
knowing.  On openSUSE the grub config is built from the files in
/etc/grub.d/ so any package can add a kernel option (and various
conditions around activating it) simply by adding a new file.  The
config files are quite sophisticated, so you can add what looks to be a
new kernel, but is really an existing kernel with different options
this way.

James
