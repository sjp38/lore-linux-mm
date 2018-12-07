Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0118B8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 14:59:24 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so4195508pfa.18
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 11:59:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u3si3717929plb.99.2018.12.07.11.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 11:59:24 -0800 (PST)
Date: Fri, 7 Dec 2018 11:56:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/sparse: add common helper to mark all memblocks
 present
Message-Id: <20181207115626.dd578402f407e3df798aad0c@linux-foundation.org>
In-Reply-To: <71168447-7470-d2ba-d30e-200ff6202b35@deltatee.com>
References: <20181107173859.24096-1-logang@deltatee.com>
	<20181107173859.24096-3-logang@deltatee.com>
	<20181107121207.62cb37cf58484b7cc80a8fd8@linux-foundation.org>
	<71168447-7470-d2ba-d30e-200ff6202b35@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>

On Thu, 6 Dec 2018 10:40:31 -0700 Logan Gunthorpe <logang@deltatee.com> wrote:

> Hey Andrew,
> 
> On 2018-11-07 1:12 p.m., Andrew Morton wrote:
> > Acked-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > I can grab both patches and shall sneak them into 4.20-rcX, but feel
> > free to merge them into some git tree if you'd prefer.  If I see them
> > turn up in linux-next I shall drop my copy.
> 
> Just wanted to check if you are still planning to get these patches into
> 4.20-rcX. It would really help us if you can do this seeing we then
> won't have to delay a cycle and can target the riscv sparsemem code for
> 4.21.
> 

Ah, OK, I assumed that it would be merged via an arm tree.

I moved 

mm-introduce-common-struct_page_max_shift-define.patch
mm-sparse-add-common-helper-to-mark-all-memblocks-present.patch

to head-of-queue.  Shall send to Linus next week.
