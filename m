Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 278276B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 07:24:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 91-v6so18607002pla.18
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 04:24:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id l20si5773399pff.297.2018.04.05.04.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 04:24:17 -0700 (PDT)
Date: Thu, 5 Apr 2018 04:23:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 1/5] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm and arm64
Message-ID: <20180405112357.GA2647@bombadil.infradead.org>
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
 <1522915478-5044-2-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522915478-5044-2-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <jia.he@hxt-semitech.com>

On Thu, Apr 05, 2018 at 01:04:34AM -0700, Jia He wrote:
>  create mode 100644 include/linux/arm96_common.h

'arm96_common'?!  No.  Just no.

The right way to share common code is to create a header file (or use
an existing one), either in asm-generic or linux, with a #ifdef CONFIG_foo
block and then 'select foo' in the arm Kconfig files.  That allows this
common code to be shared, maybe with powerpc or x86 or ... in the future.
