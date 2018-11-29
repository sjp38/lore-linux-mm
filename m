Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 360606B504F
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 21:53:34 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h86-v6so453231pfd.2
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 18:53:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor585614plt.31.2018.11.28.18.53.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 18:53:33 -0800 (PST)
Date: Thu, 29 Nov 2018 11:53:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc.c: Fix zsmalloc 32-bit PAE support
Message-ID: <20181129025328.GE6379@jagdpanzerIV>
References: <20181025134344.GZ30658@n2100.armlinux.org.uk>
 <20181121001150.405-1-rafael.tinoco@linaro.org>
 <91776bf8-0d12-1cc4-1ffb-ca3c486aeb0b@linaro.org>
 <93b0cce5-4ceb-14ab-5987-af54f15958f2@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <93b0cce5-4ceb-14ab-5987-af54f15958f2@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael David Tinoco <rafael.tinoco@linaro.org>
Cc: linux@armlinux.org.uk, broonie@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com

On (11/27/18 18:33), Rafael David Tinoco wrote:
> On 11/20/18 10:18 PM, Rafael David Tinoco wrote:
> > 
> > Russell,
> > 
> > I have tried to place MAX_POSSIBLE_PHYSMEM_BITS in the best available
> > header for each architecture, considering different paging levels, PAE
> > existence, and existing similar definitions. Also, I have only
> > considered those architectures already having "sparsemem.h" header.
> > 
> > Would you mind reviewing it ?
> 
> Should I re-send the this v2 (as v3) with complete list of
> get_maintainer.pl ? I was in doubt because I'm touching headers from
> several archs and I'm not sure who, if it is accepted, would merge it.

Yes, resending and Cc-ing archs' maintainers if the right thing to do.
It's also possible that they will ask to split the patch and do a
per-arch change.

	-ss
