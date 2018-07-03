Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3200C6B000A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:30:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a3-v6so1146427wrr.12
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:30:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l11-v6si1030612wrq.409.2018.07.03.08.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 08:30:29 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w63FNx1K081839
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 11:30:28 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0autu4ar-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 11:30:28 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 3 Jul 2018 16:30:26 +0100
Date: Tue, 3 Jul 2018 18:30:20 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] m68k/page_no.h: force __va argument to be unsigned
 long
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703142054.GL16767@dhcp22.suse.cz>
 <20180703150315.GC4809@rapoport-lnx>
 <20180703150535.GA21590@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703150535.GA21590@bombadil.infradead.org>
Message-Id: <20180703153019.GD4809@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 08:05:35AM -0700, Matthew Wilcox wrote:
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

Historically?

It started off with unsigned long, then commit e5f270954364 ("[LMB]: Make
lmb support large physical addressing") converted it to u64 for 32-bit
systems sake.

And the definition of ARCH_PHYS_ADDR_T_64BIT in commit 600715dcdf56
("generic: add phys_addr_t for holding physical addresses")) came in later.
    

-- 
Sincerely yours,
Mike.
