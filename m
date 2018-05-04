Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 418426B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:54:27 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y7-v6so16435111qtn.3
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:54:27 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n12-v6si1755333qtb.361.2018.05.04.09.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 09:54:26 -0700 (PDT)
Subject: Re: [PATCH v8 0/6] optimize memblock_next_valid_pfn and
 early_pfn_valid on arm and arm64
References: <1523431317-30612-1-git-send-email-hejianet@gmail.com>
 <05b0fcf2-7670-101e-d4ab-1f656ff6b02f@gmail.com>
 <CACjP9X8bHmrxmd7ZPcfQq6Eq0Mzwmt0saOR3Ph53gp2n-dcKBQ@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <23b14717-0f4a-10f2-5118-7cb8445fbdab@oracle.com>
Date: Fri, 4 May 2018 12:53:40 -0400
MIME-Version: 1.0
In-Reply-To: <CACjP9X8bHmrxmd7ZPcfQq6Eq0Mzwmt0saOR3Ph53gp2n-dcKBQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>, Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, open list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

> I'm wondering, ain't simple enabling of config
> DEFERRED_STRUCT_PAGE_INIT provide even better speed-up? If that is the
> case then it seems like this series is not needed at all, right?
> I am not sure why is this config optional. It looks like it could be
> enabled by default or even unconditionally considering that with
> commit c9e97a1997fb ("mm: initialize pages on demand during boot") the
> deferred code is statically disabled after all the pages are
> initialized.

Hi Daniel,

Currently, deferred struct pages are initialized in parallel only on NUMA machines. I would like to make a change to use all the available CPUs even on a single socket systems, but that is not there yet. So, I believe Jia's performance improvements are still relevant.

Thank you,
Pavel
