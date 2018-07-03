Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2396B026F
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:06:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u16-v6so1196330pfm.15
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:06:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w37-v6si1269488pgl.514.2018.07.03.08.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Jul 2018 08:06:17 -0700 (PDT)
Date: Tue, 3 Jul 2018 08:05:35 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/3] m68k/page_no.h: force __va argument to be unsigned
 long
Message-ID: <20180703150535.GA21590@bombadil.infradead.org>
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703142054.GL16767@dhcp22.suse.cz>
 <20180703150315.GC4809@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703150315.GC4809@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 06:03:16PM +0300, Mike Rapoport wrote:
> On Tue, Jul 03, 2018 at 04:20:54PM +0200, Michal Hocko wrote:
> > On Tue 03-07-18 13:29:54, Mike Rapoport wrote:
> > > Add explicit casting to unsigned long to the __va() parameter
> > 
> > Why is this needed?
> 
> To make it consitent with other architecures and asm-generic :)
> 
> But more importantly, __memblock_free_late() passes u64 to page_to_pfn().

Why does memblock work in terms of u64 instead of phys_addr_t?
