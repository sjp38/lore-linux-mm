Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 359B36B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 07:38:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n2-v6so5576736edr.5
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 04:38:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a13-v6si1296802edb.300.2018.07.02.04.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 04:38:54 -0700 (PDT)
Date: Mon, 2 Jul 2018 13:38:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 2/6] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm/arm64
Message-ID: <20180702113851.GI19043@dhcp22.suse.cz>
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
 <1530239363-2356-3-git-send-email-hejianet@gmail.com>
 <CAGM2reYn3ZbdjhcZze8Zt1eLNSdWghy0KwEXfd5xW+1Ba_SMbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reYn3ZbdjhcZze8Zt1eLNSdWghy0KwEXfd5xW+1Ba_SMbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: hejianet@gmail.com, linux@armlinux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, will.deacon@arm.com, mark.rutland@arm.com, hpa@zytor.com, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, neelx@redhat.com, erosca@de.adit-jv.com, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, james.morse@arm.com, ard.biesheuvel@linaro.org, steve.capper@arm.com, tglx@linutronix.de, mingo@redhat.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, pombredanne@nexb.com, Johannes Weiner <hannes@cmpxchg.org>, kemi.wang@intel.com, ptesarik@suse.com, yasu.isimatu@gmail.com, aryabinin@virtuozzo.com, nborisov@suse.com, Wei Yang <richard.weiyang@gmail.com>, jia.he@hxt-semitech.com

On Fri 29-06-18 14:13:08, Pavel Tatashin wrote:
> > +++ b/include/linux/early_pfn.h
> > @@ -0,0 +1,34 @@
> > +/* SPDX-License-Identifier: GPL-2.0 */
> > +/* Copyright (C) 2018 HXT-semitech Corp. */
> > +#ifndef __EARLY_PFN_H
> > +#define __EARLY_PFN_H
> > +#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
> > +ulong __init_memblock memblock_next_valid_pfn(ulong pfn)
> > +{
> > +       struct memblock_type *type = &memblock.memory;
> 
> Why put it in a header file and not in some C file? In my opinion it
> is confusing to have non-line functions in header files. Basically,
> you can include this header file in exactly one C file without
> breaking compilation.

It is not confusing. It is outright broken.

-- 
Michal Hocko
SUSE Labs
