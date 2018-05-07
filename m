Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7F56B000C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 08:23:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e20so23241635pff.14
        for <linux-mm@kvack.org>; Mon, 07 May 2018 05:23:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p23-v6si17436001pgv.153.2018.05.07.05.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 05:23:49 -0700 (PDT)
Date: Mon, 7 May 2018 05:23:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Proof-of-concept: better(?) page-table manipulation API
Message-ID: <20180507122346.GE18116@bombadil.infradead.org>
References: <20180424154355.mfjgkf47kdp2by4e@black.fi.intel.com>
 <CALCETrVzD8oPv=h2q91AMdCHn3S782GmvsY-+mwoaPUw=5N7HQ@mail.gmail.com>
 <20180507113124.ewpbrfd3anyg7pli@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507113124.ewpbrfd3anyg7pli@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andy Lutomirski <luto@amacapital.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 07, 2018 at 02:31:25PM +0300, Kirill A. Shutemov wrote:
> > Also, what does lvl == 0 mean?  Is it the top or the bottom?  I think a
> > comment would be helpful.
> 
> It is bottom. But it should be up to architecture to decide.

That's not true because ...

> > > +static inline void ptp_walk(ptp_t *ptp, unsigned long addr)
> > > +{
> > > +       ptp->ptr = (unsigned long *)ptp_page_vaddr(ptp);
> > > +       ptp->ptr += __pt_index(addr, --ptp->lvl);
> > > +}
> > 
> > Can you add a comment that says what this function does?
> 
> Okay, I will.
> 
> > Why does it not change the level?
> 
> It does. --ptp->lvl.

... you've hardcoded that walking down decrements the level by 1.

I don't see that as a defect; it's just part of the API that needs
documenting.
