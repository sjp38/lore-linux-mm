Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8946B000D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:39:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x6-v6so1177193wrl.6
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:39:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 7-v6si1138933wrd.136.2018.07.03.08.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 08:39:43 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w63FdM2s133100
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 11:39:42 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0autuhnp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 11:39:41 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 3 Jul 2018 16:39:40 +0100
Date: Tue, 3 Jul 2018 18:39:33 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] m68k/page_no.h: force __va argument to be unsigned
 long
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703142054.GL16767@dhcp22.suse.cz>
 <20180703150315.GC4809@rapoport-lnx>
 <20180703150535.GA21590@bombadil.infradead.org>
 <20180703151401.GQ16767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703151401.GQ16767@dhcp22.suse.cz>
Message-Id: <20180703153932.GE4809@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 05:14:01PM +0200, Michal Hocko wrote:
> On Tue 03-07-18 08:05:35, Matthew Wilcox wrote:
> > On Tue, Jul 03, 2018 at 06:03:16PM +0300, Mike Rapoport wrote:
> > > On Tue, Jul 03, 2018 at 04:20:54PM +0200, Michal Hocko wrote:
> > > > On Tue 03-07-18 13:29:54, Mike Rapoport wrote:
> > > > > Add explicit casting to unsigned long to the __va() parameter
> > > > 
> > > > Why is this needed?
> > > 
> > > To make it consitent with other architecures and asm-generic :)
> > > 
> > > But more importantly, __memblock_free_late() passes u64 to page_to_pfn().
> > 
> > Why does memblock work in terms of u64 instead of phys_addr_t?
> 
> Yes, phys_addr_t was exactly that came to my mind as well. Casting
> physical address to unsigned long just screams for potential problems.

Heh, that's what we have:

~/git/linux $ git grep 'define __va.*\(unsigned long\)' | wc -l
22
 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
