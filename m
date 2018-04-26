Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7636B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:22:48 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id w2-v6so20395685qti.8
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 08:22:48 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b31-v6si5156176qtc.325.2018.04.26.08.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 08:22:46 -0700 (PDT)
Date: Thu, 26 Apr 2018 11:22:38 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc fallback
 options
In-Reply-To: <alpine.LRH.2.02.1804261045001.9108@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1804261116470.14894@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804261045001.9108@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="185206533-997862569-1524756159=:14894"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: David Rientjes <rientjes@google.com>, dm-devel@redhat.com, eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, edumazet@google.com, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, Vlastimil Babka <vbabka@suse.cz>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--185206533-997862569-1524756159=:14894
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT



On Thu, 26 Apr 2018, Mikulas Patocka wrote:

> 
> 
> On Wed, 25 Apr 2018, James Bottomley wrote:
> 
> > > BTW. even developers who compile their own kernel should have this
> > > enabled by a CONFIG option - because if the developer sees the option
> > > when browsing through menuconfig, he may enable it. If he doesn't see
> > > the option, he won't even know that such an option exists.
> > 
> > I may be an atypical developer but I'd rather have a root canal than
> > browse through menuconfig options.  The way to get people to learn
> > about new debugging options is to blog about it (or write an lwn.net
> > article) which google will find the next time I ask it how I debug XXX.
> >  Google (probably as a service to humanity) rarely turns up Kconfig
> > options in response to a query.
> 
> From my point of view, this feature should be as little disruptive to the 
> developer as possible. It should work automatically behind the scenes 
> without the developer or the tester even knowing that it is working. From 
> this point of view, binding it to CONFIG_DEBUG_SG (or any other commonly 
> used debugging option) would be ideal, because driver developers already 
> enable CONFIG_DEBUG_SG, so they'll get this kvmalloc test for free.
> 
> From your point of view, you should introduce a sysfs file and a kernel 
> parameter that no one knows about - and then start blogging about it - to 
> let people know. Why would you bother people with this knowledge? They'll 
> forget about it anyway and won't turn it on.

BTW. try to think about - how many total lines of code should this feature 
consume in the whole Linux ecosystem?

I made a 10-line patch. I got pushback.

I remade it to a 53-line patch. And you try to suggest that 53 lines is 
not enough and we must also change kernel packaging scripts in distro 
kernels, because the kernel just cannot enable this feature on its own.

If we hack kernel packaging scripts in most distros, how many lines of 
code would that be? What's your target?

Mikulas
--185206533-997862569-1524756159=:14894--
