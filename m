Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 194A66B05A4
	for <linux-mm@kvack.org>; Wed,  9 May 2018 21:15:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x7-v6so292927wrm.13
        for <linux-mm@kvack.org>; Wed, 09 May 2018 18:15:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a50-v6si4363349edc.429.2018.05.09.18.15.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 18:15:20 -0700 (PDT)
Date: Thu, 10 May 2018 01:15:16 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for
 architectures
Message-ID: <20180510011516.GZ27853@wotan.suse.de>
References: <20180428001526.22475-1-mcgrof@kernel.org>
 <20180428031810.GA14566@bombadil.infradead.org>
 <20180509010438.GM27853@wotan.suse.de>
 <20180509013935.GA8131@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509013935.GA8131@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, Tony Luck <tony.luck@intel.com>, arnd@arndb.de, gregkh@linuxfoundation.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, May 08, 2018 at 06:39:35PM -0700, Matthew Wilcox wrote:
> On Wed, May 09, 2018 at 01:04:38AM +0000, Luis R. Rodriguez wrote:
> > On Fri, Apr 27, 2018 at 08:18:10PM -0700, Matthew Wilcox wrote:
> > > ia64: Add PAGE_KERNEL_RO and PAGE_KERNEL_EXEC
> > > 
> > > The rest of the kernel was falling back to simple PAGE_KERNEL pages; using
> > > PAGE_KERNEL_RO and PAGE_KERNEL_EXEC provide better protection against
> > > unintended writes.
> > > 
> > > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Nice, should I queue this into my series as well?
> 
> A little reluctant to queue it without anyone having tested it.  Heck,
> I didn't even check it compiled ;-)
> 
> We used to just break architectures and let them fix it up for this kind
> of thing.

History is wonderful.

> That's not really acceptable nowadays, but I don't know how
> we get arch maintainers to fix up their ports now.

OK then in that case I'll proceed with my patches for now and just
document they don't have it. Once and folks test the patch we can
consider it.

  Luis
