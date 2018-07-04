Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57AE06B0010
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 03:23:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b17-v6so892065pff.17
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:23:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x32-v6sor976438pld.141.2018.07.04.00.23.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 00:23:13 -0700 (PDT)
Date: Wed, 4 Jul 2018 16:23:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
Message-ID: <20180704072308.GA458@jagdpanzerIV>
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
 <20180704070305.GB4352@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704070305.GB4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>

On (07/04/18 10:03), Mike Rapoport wrote:
> > %p[Ff] got deprecated by commit 04b8eb7a4ccd9ef9343e2720ccf2a5db8cfe2f67
> > 
> > I think it'd be simplest to just convert
> > all the %pF and %pf uses all at once.
> > 
> > $ git grep --name-only "%p[Ff]" | \
> >   xargs sed -i -e 's/%pF/%pS/' -e 's/%pf/%ps/'
> > 
> > and remove the appropriate Documentation bit.
> > 
> 
> Something like this:
> 
> From 0d3e7cf494123c2640b9a892160d2e2430787004 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Date: Wed, 4 Jul 2018 09:55:50 +0300
> Subject: [PATCH] treewide: retire '%pF/%pf'
> 
> %p[Ff] got deprecated by commit 04b8eb7a4ccd9ef9343e2720ccf2a5db8cfe2f67
> ("symbol lookup: introduce dereference_symbol_descriptor()")
> 
> Replace their uses with %p[Ss] with
> 
> $ git grep --name-only "%p[Ff]" | \
>   xargs sed -i -e 's/%pF/%pS/' -e 's/%pf/%ps/'


Sorry, NACK on lib/vsprintf.c part

I definitely didn't want to do this tree-wide pf->ps conversion when
I introduced my patch set. pf/pF should have never existed, true,
but I think we must support pf/pF in vsprintf(). Simply because it
has been around for *far* too long. People tend to develop "habits",
you know, I'm quite sure ppc/hppa/etc folks still do [and will] use
pf/pF occasionally.

	-ss
