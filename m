Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B767A6B0273
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:55:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h17-v6so748734edq.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:55:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g44-v6si1144527edc.326.2018.07.03.08.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 08:55:09 -0700 (PDT)
Date: Tue, 3 Jul 2018 17:55:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] m68k/page_no.h: force __va argument to be unsigned
 long
Message-ID: <20180703155505.GS16767@dhcp22.suse.cz>
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703142054.GL16767@dhcp22.suse.cz>
 <20180703150315.GC4809@rapoport-lnx>
 <20180703150535.GA21590@bombadil.infradead.org>
 <20180703151401.GQ16767@dhcp22.suse.cz>
 <20180703154751.GF4809@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703154751.GF4809@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 03-07-18 18:47:51, Mike Rapoport wrote:
> On Tue, Jul 03, 2018 at 05:14:01PM +0200, Michal Hocko wrote:
> > On Tue 03-07-18 08:05:35, Matthew Wilcox wrote:
> > > On Tue, Jul 03, 2018 at 06:03:16PM +0300, Mike Rapoport wrote:
> > > > On Tue, Jul 03, 2018 at 04:20:54PM +0200, Michal Hocko wrote:
> > > > > On Tue 03-07-18 13:29:54, Mike Rapoport wrote:
> > > > > > Add explicit casting to unsigned long to the __va() parameter
> > > > > 
> > > > > Why is this needed?
> > > > 
> > > > To make it consitent with other architecures and asm-generic :)
> > > > 
> > > > But more importantly, __memblock_free_late() passes u64 to page_to_pfn().
> > > 
> > > Why does memblock work in terms of u64 instead of phys_addr_t?
> > 
> > Yes, phys_addr_t was exactly that came to my mind as well. Casting
> > physical address to unsigned long just screams for potential problems.
> 
> Not sure if for m68k-nommu the physical address can really go beyond 32
> bits, but in general this is something that should be taken care of.
> 
> I think adding the cast in m68k-nommu case is a viable band aid to allow
> sorting out the bootmem vs nobootmem.
> 
> In any case care should be taken of all those
> 
> 	#define __va(x)	((void *)((unsigned long)(x))) 

Yeah, sounds like a good idea to me.

> all around.
> 
> Regardless, I can s/u64/phys_addr_t/ in memblock.c.

Yeah, sounds like a good thing to me.

-- 
Michal Hocko
SUSE Labs
