Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC1D06B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 05:43:50 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n20-v6so2226679pgv.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 02:43:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n88-v6sor901061pfk.63.2018.07.04.02.43.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 02:43:49 -0700 (PDT)
Date: Wed, 4 Jul 2018 18:43:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
Message-ID: <20180704094344.GD458@jagdpanzerIV>
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
 <20180704070305.GB4352@rapoport-lnx>
 <20180704072308.GA458@jagdpanzerIV>
 <8dc61092669356f5417bc275e3b7c69ce637e63e.camel@perches.com>
 <20180704092042.GC458@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704092042.GC458@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/04/18 18:20), Sergey Senozhatsky wrote:
> > There's this saying about habits made to be broken.
> > This is one of those habits.
> > 
> > I'd expect more people probably get the %pS or %ps wrong
> > than use %pF.
> > 
> > And most people probably look for examples in code and
> > copy instead of thinking what's correct, so removing old
> > and deprecated uses from existing code is a good thing.
> 
> Well, I don't NACK the patch, I just want to keep pf/pF in vsprintf(),
> that's it. Yes, checkpatch warns about pf/pF uses, becuase we don't want
> any new pf/pF in the code - it's rather confusing to have both pf/pF and
> ps/pS -- but I don't necessarily see why would we want to mess up with
> parisc/hppa/ia64 people using pf/pF for debugging purposes, etc. I'm not
> married to pf/pF, if you guys insist on complete removal of pf/pF then so
> be it.

And just for the record - I think the reason why I didn't feel like
doing a tree wide pf->ps conversion was that some of those pf->ps
printk-s could end up in -stable backports [sure, no one backports
print out changes, but a print out can be part of a fix which gets
backported, etc]. So I just decided to stay away from this. IIRC.

	-ss
