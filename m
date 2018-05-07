Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7A9F6B000C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 09:11:04 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s7-v6so17773928pgp.15
        for <linux-mm@kvack.org>; Mon, 07 May 2018 06:11:04 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k6-v6si17527151pgq.85.2018.05.07.06.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 06:11:03 -0700 (PDT)
Date: Mon, 7 May 2018 16:10:59 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: Proof-of-concept: better(?) page-table manipulation API
Message-ID: <20180507131059.3cdpfd4dcnwznhyw@black.fi.intel.com>
References: <20180424154355.mfjgkf47kdp2by4e@black.fi.intel.com>
 <CALCETrVzD8oPv=h2q91AMdCHn3S782GmvsY-+mwoaPUw=5N7HQ@mail.gmail.com>
 <20180507113124.ewpbrfd3anyg7pli@kshutemo-mobl1>
 <20180507122346.GE18116@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507122346.GE18116@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 07, 2018 at 12:23:46PM +0000, Matthew Wilcox wrote:
> On Mon, May 07, 2018 at 02:31:25PM +0300, Kirill A. Shutemov wrote:
> > > Also, what does lvl == 0 mean?  Is it the top or the bottom?  I think a
> > > comment would be helpful.
> > 
> > It is bottom. But it should be up to architecture to decide.
> 
> That's not true because ...
> 
> > > > +static inline void ptp_walk(ptp_t *ptp, unsigned long addr)
> > > > +{
> > > > +       ptp->ptr = (unsigned long *)ptp_page_vaddr(ptp);
> > > > +       ptp->ptr += __pt_index(addr, --ptp->lvl);
> > > > +}
> > > 
> > > Can you add a comment that says what this function does?
> > 
> > Okay, I will.
> > 
> > > Why does it not change the level?
> > 
> > It does. --ptp->lvl.
> 
> ... you've hardcoded that walking down decrements the level by 1.
> 
> I don't see that as a defect; it's just part of the API that needs
> documenting.

You assume that the function is a generic one. This may or may not be
true.

This is subject for refinement anyway.

-- 
 Kirill A. Shutemov
