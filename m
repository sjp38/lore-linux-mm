Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7BB96B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:55:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b202so8320136qkc.6
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:55:46 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p52-v6si5907972qtc.122.2018.04.26.07.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:55:45 -0700 (PDT)
Date: Thu, 26 Apr 2018 10:55:44 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc fallback
 options
In-Reply-To: <1524697697.4100.23.camel@HansenPartnership.com>
Message-ID: <alpine.LRH.2.02.1804261045001.9108@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org>   <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>   <20180423151545.GU17484@dhcp22.suse.cz>   <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
  <20180424125121.GA17484@dhcp22.suse.cz>   <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com>   <20180424162906.GM17484@dhcp22.suse.cz>   <alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>  
 <20180424170349.GQ17484@dhcp22.suse.cz>   <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>   <20180424173836.GR17484@dhcp22.suse.cz>   <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>  
 <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>   <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>   <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>   <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
  <1524694663.4100.21.camel@HansenPartnership.com>  <alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com> <1524697697.4100.23.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="185206533-886270301-1524754049=:9108"
Content-ID: <alpine.LRH.2.02.1804261047430.9108@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: David Rientjes <rientjes@google.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--185206533-886270301-1524754049=:9108
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LRH.2.02.1804261047431.9108@file01.intranet.prod.int.rdu2.redhat.com>



On Wed, 25 Apr 2018, James Bottomley wrote:

> > BTW. even developers who compile their own kernel should have this
> > enabled by a CONFIG option - because if the developer sees the option
> > when browsing through menuconfig, he may enable it. If he doesn't see
> > the option, he won't even know that such an option exists.
> 
> I may be an atypical developer but I'd rather have a root canal than
> browse through menuconfig options.  The way to get people to learn
> about new debugging options is to blog about it (or write an lwn.net
> article) which google will find the next time I ask it how I debug XXX.
>  Google (probably as a service to humanity) rarely turns up Kconfig
> options in response to a query.

>From my point of view, this feature should be as little disruptive to the 
developer as possible. It should work automatically behind the scenes 
without the developer or the tester even knowing that it is working. From 
this point of view, binding it to CONFIG_DEBUG_SG (or any other commonly 
used debugging option) would be ideal, because driver developers already 
enable CONFIG_DEBUG_SG, so they'll get this kvmalloc test for free.

>From your point of view, you should introduce a sysfs file and a kernel 
parameter that no one knows about - and then start blogging about it - to 
let people know. Why would you bother people with this knowledge? They'll 
forget about it anyway and won't turn it on.

Mikulas
--185206533-886270301-1524754049=:9108--
