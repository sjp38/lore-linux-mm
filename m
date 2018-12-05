Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2DA16B75D4
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 14:00:22 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so17444939pfa.18
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 11:00:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z75sor16225180pfi.15.2018.12.05.11.00.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 11:00:21 -0800 (PST)
Date: Wed, 5 Dec 2018 11:00:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
In-Reply-To: <CAFgQCTttgfuPJZHqGDSF5hLpLWDm2+_+UiyK+ScKgxs6qD-KCQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1812051058440.240991@chino.kir.corp.google.com>
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com> <alpine.DEB.2.21.1812031946140.97328@chino.kir.corp.google.com> <CAFgQCTsikqQERh2MgsrupdVzp0TyF4dDQPjJkN9g3DTq4DB9hw@mail.gmail.com>
 <CAFgQCTttgfuPJZHqGDSF5hLpLWDm2+_+UiyK+ScKgxs6qD-KCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Wed, 5 Dec 2018, Pingfan Liu wrote:

> > > And rather than using first_online_node, would next_online_node() work?
> > >
> > What is the gain? Is it for memory pressure on node0?
> >
> Maybe I got your point now.  Do you try to give a cheap assumption on
> nearest neigh of this node?
> 

It's likely better than first_online_node, but probably going to be the 
same based on the node ids that you have reported since the nodemask will 
simply wrap around back to the first node.
