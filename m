Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4874E6B000D
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:13:49 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h195-v6so2517965itb.3
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:13:49 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m68-v6si1308355itc.75.2018.06.29.11.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 11:13:48 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5TIDlqc122362
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:13:47 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2120.oracle.com with ESMTP id 2jukhsqmw5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:13:47 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5TIDjnj010670
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:13:45 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5TIDjIL018380
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:13:45 GMT
Received: by mail-ot0-f173.google.com with SMTP id c15-v6so10865674otl.3
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:13:44 -0700 (PDT)
MIME-Version: 1.0
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com> <1530239363-2356-3-git-send-email-hejianet@gmail.com>
In-Reply-To: <1530239363-2356-3-git-send-email-hejianet@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 29 Jun 2018 14:13:08 -0400
Message-ID: <CAGM2reYn3ZbdjhcZze8Zt1eLNSdWghy0KwEXfd5xW+1Ba_SMbw@mail.gmail.com>
Subject: Re: [PATCH v9 2/6] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm/arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hejianet@gmail.com
Cc: linux@armlinux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, will.deacon@arm.com, mark.rutland@arm.com, hpa@zytor.com, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, neelx@redhat.com, erosca@de.adit-jv.com, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, james.morse@arm.com, ard.biesheuvel@linaro.org, steve.capper@arm.com, tglx@linutronix.de, mingo@redhat.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, pombredanne@nexb.com, Johannes Weiner <hannes@cmpxchg.org>, kemi.wang@intel.com, ptesarik@suse.com, yasu.isimatu@gmail.com, aryabinin@virtuozzo.com, nborisov@suse.com, Wei Yang <richard.weiyang@gmail.com>, jia.he@hxt-semitech.com

> +++ b/include/linux/early_pfn.h
> @@ -0,0 +1,34 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +/* Copyright (C) 2018 HXT-semitech Corp. */
> +#ifndef __EARLY_PFN_H
> +#define __EARLY_PFN_H
> +#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
> +ulong __init_memblock memblock_next_valid_pfn(ulong pfn)
> +{
> +       struct memblock_type *type = &memblock.memory;

Why put it in a header file and not in some C file? In my opinion it
is confusing to have non-line functions in header files. Basically,
you can include this header file in exactly one C file without
breaking compilation.
