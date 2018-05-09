Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55D246B0309
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:04:49 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id a6-v6so2772986pll.22
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:04:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8-v6si15175036plm.121.2018.05.08.18.04.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 May 2018 18:04:48 -0700 (PDT)
Date: Wed, 9 May 2018 01:04:38 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for
 architectures
Message-ID: <20180509010438.GM27853@wotan.suse.de>
References: <20180428001526.22475-1-mcgrof@kernel.org>
 <20180428031810.GA14566@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180428031810.GA14566@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Tony Luck <tony.luck@intel.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, arnd@arndb.de, gregkh@linuxfoundation.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Fri, Apr 27, 2018 at 08:18:10PM -0700, Matthew Wilcox wrote:
> On Fri, Apr 27, 2018 at 05:15:26PM -0700, Luis R. Rodriguez wrote:
> > Some architectures do not define PAGE_KERNEL_RO, best we can do
> > for them is to provide a fallback onto PAGE_KERNEL. Remove the
> > hack from the firmware loader and move it onto the asm-generic
> > header, and document while at it the affected architectures
> > which do not have a PAGE_KERNEL_RO:
> > 
> >   o alpha
> >   o ia64
> >   o m68k
> >   o mips
> >   o sparc64
> >   o sparc
> 
> ia64 doesn't have it?
> 
> *fx: riffles through architecture book*
> 
> That seems like an oversight of the Linux port.  Tony, Fenghua, any thoughts?

Poke *Tony, Fenghua* ?

> (also, Luis, maybe move the PAGE_KERNEL_EXEC fallback the same way you
> moved the PAGE_KERNEL_RO fallback?)

Done. Will queue in the generic PAGE_KERNEL_EXEC patch to my series.

> --- >8 ---
> 
> ia64: Add PAGE_KERNEL_RO and PAGE_KERNEL_EXEC
> 
> The rest of the kernel was falling back to simple PAGE_KERNEL pages; using
> PAGE_KERNEL_RO and PAGE_KERNEL_EXEC provide better protection against
> unintended writes.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Nice, should I queue this into my series as well?

  Luis
