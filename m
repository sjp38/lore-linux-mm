Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7536B000C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 03:28:40 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 31-v6so761687plf.19
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 00:28:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4-v6si470239pgy.251.2018.07.03.00.28.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 00:28:39 -0700 (PDT)
Date: Tue, 3 Jul 2018 09:28:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 0/6] optimize memblock_next_valid_pfn and
 early_pfn_valid on arm and arm64
Message-ID: <20180703072835.GE16767@dhcp22.suse.cz>
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
 <20180702114037.GJ19043@dhcp22.suse.cz>
 <779be6bf-db64-9175-f4c0-2baa0ea6defd@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <779be6bf-db64-9175-f4c0-2baa0ea6defd@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com

On Tue 03-07-18 10:11:11, Jia He wrote:
> On 7/2/2018 7:40 PM, Michal Hocko Wrote:
[...]
> > So this is 13ms saving when booting 96G machine. Is this really worth
> > the additional code? Are there any other benefits?
> Sorry, Michal
> I missed one thing.
> This 13ms optimization is merely the result of my patch 3~6
> Patch 1 is originated by Paul Burton in commit b92df1de5d289.
> In its description,
> ===
> James said "I have tested this patch on a virtual model of a Samurai CPU
>     with a sparse memory map.  The kernel boot time drops from 109 to
>     62 seconds. "
> ===

Those numbers should be in the changelog.
-- 
Michal Hocko
SUSE Labs
