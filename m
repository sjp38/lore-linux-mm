Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B11D6B0296
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:14:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h17-v6so701734edq.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:14:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z29-v6si1653790edl.302.2018.07.03.08.14.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 08:14:04 -0700 (PDT)
Date: Tue, 3 Jul 2018 17:14:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] m68k/page_no.h: force __va argument to be unsigned
 long
Message-ID: <20180703151401.GQ16767@dhcp22.suse.cz>
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703142054.GL16767@dhcp22.suse.cz>
 <20180703150315.GC4809@rapoport-lnx>
 <20180703150535.GA21590@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703150535.GA21590@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 03-07-18 08:05:35, Matthew Wilcox wrote:
> On Tue, Jul 03, 2018 at 06:03:16PM +0300, Mike Rapoport wrote:
> > On Tue, Jul 03, 2018 at 04:20:54PM +0200, Michal Hocko wrote:
> > > On Tue 03-07-18 13:29:54, Mike Rapoport wrote:
> > > > Add explicit casting to unsigned long to the __va() parameter
> > > 
> > > Why is this needed?
> > 
> > To make it consitent with other architecures and asm-generic :)
> > 
> > But more importantly, __memblock_free_late() passes u64 to page_to_pfn().
> 
> Why does memblock work in terms of u64 instead of phys_addr_t?

Yes, phys_addr_t was exactly that came to my mind as well. Casting
physical address to unsigned long just screams for potential problems.

-- 
Michal Hocko
SUSE Labs
