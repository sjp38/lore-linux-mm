Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3C116B0324
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:39:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b25so25381565pfn.10
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:39:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a68-v6si25841710pli.158.2018.05.08.18.39.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 18:39:39 -0700 (PDT)
Date: Tue, 8 May 2018 18:39:35 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for
 architectures
Message-ID: <20180509013935.GA8131@bombadil.infradead.org>
References: <20180428001526.22475-1-mcgrof@kernel.org>
 <20180428031810.GA14566@bombadil.infradead.org>
 <20180509010438.GM27853@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509010438.GM27853@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, arnd@arndb.de, gregkh@linuxfoundation.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Wed, May 09, 2018 at 01:04:38AM +0000, Luis R. Rodriguez wrote:
> On Fri, Apr 27, 2018 at 08:18:10PM -0700, Matthew Wilcox wrote:
> > ia64: Add PAGE_KERNEL_RO and PAGE_KERNEL_EXEC
> > 
> > The rest of the kernel was falling back to simple PAGE_KERNEL pages; using
> > PAGE_KERNEL_RO and PAGE_KERNEL_EXEC provide better protection against
> > unintended writes.
> > 
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Nice, should I queue this into my series as well?

A little reluctant to queue it without anyone having tested it.  Heck,
I didn't even check it compiled ;-)

We used to just break architectures and let them fix it up for this kind
of thing.  That's not really acceptable nowadays, but I don't know how
we get arch maintainers to fix up their ports now.
