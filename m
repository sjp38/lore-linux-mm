Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C28B68E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:29:07 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so4466293pgb.7
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:29:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q20si4323204pll.255.2018.12.14.10.29.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Dec 2018 10:29:06 -0800 (PST)
Date: Fri, 14 Dec 2018 10:29:04 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 4/4] mm: show number of vmalloc pages in /proc/meminfo
Message-ID: <20181214182904.GE10600@bombadil.infradead.org>
References: <20181214180720.32040-1-guro@fb.com>
 <20181214180720.32040-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214180720.32040-5-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>

On Fri, Dec 14, 2018 at 10:07:20AM -0800, Roman Gushchin wrote:
> Vmalloc() is getting more and more used these days (kernel stacks,
> bpf and percpu allocator are new top users), and the total %
> of memory consumed by vmalloc() can be pretty significant
> and changes dynamically.
> 
> /proc/meminfo is the best place to display this information:
> its top goal is to show top consumers of the memory.
> 
> Since the VmallocUsed field in /proc/meminfo is not in use
> for quite a long time (it has been defined to 0 by the
> commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
> /proc/meminfo")), let's reuse it for showing the actual
> physical memory consumption of vmalloc().

Do you see significant contention on nr_vmalloc_pages?  Also, if it's
just an atomic_long_t, is it worth having an accessor for it?  And if
it is worth having an accessor for it, then it can be static.

Also, I seem to be missing 3/4.
