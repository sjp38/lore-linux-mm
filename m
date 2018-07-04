Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C81406B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 05:20:48 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s16-v6so2750303plr.22
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 02:20:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s67-v6sor771485pfk.121.2018.07.04.02.20.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 02:20:47 -0700 (PDT)
Date: Wed, 4 Jul 2018 18:20:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
Message-ID: <20180704092042.GC458@jagdpanzerIV>
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
 <20180704070305.GB4352@rapoport-lnx>
 <20180704072308.GA458@jagdpanzerIV>
 <8dc61092669356f5417bc275e3b7c69ce637e63e.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8dc61092669356f5417bc275e3b7c69ce637e63e.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>

On (07/04/18 02:04), Joe Perches wrote:
> > Sorry, NACK on lib/vsprintf.c part
> > 
> > I definitely didn't want to do this tree-wide pf->ps conversion when
> > I introduced my patch set. pf/pF should have never existed, true,
> > but I think we must support pf/pF in vsprintf(). Simply because it
> > has been around for *far* too long.
> 
> And?  checkpatch warns about %p[Ff] uses.
> 
> > People tend to develop "habits",
> > you know, I'm quite sure ppc/hppa/etc folks still do [and will] use
> > pf/pF occasionally.
> 
> There's this saying about habits made to be broken.
> This is one of those habits.
> 
> I'd expect more people probably get the %pS or %ps wrong
> than use %pF.
> 
> And most people probably look for examples in code and
> copy instead of thinking what's correct, so removing old
> and deprecated uses from existing code is a good thing.

Well, I don't NACK the patch, I just want to keep pf/pF in vsprintf(),
that's it. Yes, checkpatch warns about pf/pF uses, becuase we don't want
any new pf/pF in the code - it's rather confusing to have both pf/pF and
ps/pS -- but I don't necessarily see why would we want to mess up with
parisc/hppa/ia64 people using pf/pF for debugging purposes, etc. I'm not
married to pf/pF, if you guys insist on complete removal of pf/pF then so
be it.

	-ss
