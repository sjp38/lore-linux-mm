Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6DE96B0022
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 17:20:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m68so9805929pfm.20
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 14:20:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c189sor5375695pfb.33.2018.04.25.14.20.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 14:20:08 -0700 (PDT)
Date: Wed, 25 Apr 2018 14:20:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: don't show nr_indirectly_reclaimable in
 /proc/vmstat
In-Reply-To: <20180425210143.GA10277@castle>
Message-ID: <alpine.DEB.2.21.1804251419040.166306@chino.kir.corp.google.com>
References: <20180425191422.9159-1-guro@fb.com> <alpine.DEB.2.21.1804251235330.151692@chino.kir.corp.google.com> <20180425210143.GA10277@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 25 Apr 2018, Roman Gushchin wrote:

> > > Don't show nr_indirectly_reclaimable in /proc/vmstat,
> > > because there is no need in exporting this vm counter
> > > to the userspace, and some changes are expected
> > > in reclaimable object accounting, which can alter
> > > this counter.
> > > 
> > 
> > I don't think it should be a per-node vmstat, in this case.  It appears 
> > only to be used for the global context.  Shouldn't this be handled like 
> > totalram_pages, total_swap_pages, totalreserve_pages, etc?
> 
> Hi, David!
> 
> I don't see any reasons why re-using existing infrastructure for
> fast vm counters is bad, and why should we re-invent it for this case.
> 

Because now you have to modify the existing infrastructure for something 
that shouldn't be a vmstat in the first place?
