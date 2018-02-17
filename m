Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 759BE6B0005
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 17:48:22 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o20so3693722wro.3
        for <linux-mm@kvack.org>; Sat, 17 Feb 2018 14:48:22 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id v7si15081827wrd.168.2018.02.17.14.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Feb 2018 14:48:19 -0800 (PST)
Date: Sat, 17 Feb 2018 23:48:06 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH v3 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180217224806.GA32581@vmlxhi-102.adit-jv.com>
References: <20180124143545.31963-1-erosca@de.adit-jv.com>
 <20180124143545.31963-2-erosca@de.adit-jv.com>
 <20180129184746.GK21609@dhcp22.suse.cz>
 <20180203122422.GA11832@vmlxhi-102.adit-jv.com>
 <20180212150314.GG3443@dhcp22.suse.cz>
 <20180212161640.GA30811@vmlxhi-102.adit-jv.com>
 <20180212184759.GI3443@dhcp22.suse.cz>
 <20180216164328.de7d37584409e827c396bf69@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180216164328.de7d37584409e827c396bf69@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eugeniu Rosca <erosca@de.adit-jv.com>, Eugeniu Rosca <rosca.eugeniu@gmail.com>

Hello Andrew,

On Fri, Feb 16, 2018 at 04:43:28PM -0800, Andrew Morton wrote:
> On Mon, 12 Feb 2018 19:47:59 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > prerequisite for this is to reach some agreement on what people think is
> > > the best option, which I feel didn't occur yet.
> > 
> > I do not have a _strong_ preference here as well. So I will leave the
> > decision to you.
> > 
> > In any case feel free to add
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> I find Michal's version to be a little tidier.
> 
> Eugeniu, please send Michal's patch at me with a fresh changelog, with
> your signed-off-by and your tested-by and your reported-by and we may
> as well add Michal's (thus-far-missing) signed-off-by ;)

I only needed to apply below touch to Michal's patch, which otherwise
works fine for me. I've sent it to you as v4. Thank you very much for
picking it.

Best regards,
Eugeniu.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb3f844092ad..66891b3fb144 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5356,7 +5356,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
                         * end_pfn), such that we hit a valid pfn (or end_pfn)
                         * on our next iteration of the loop.
                         */
-                       if IS_ENABLED(HAVE_MEMBLOCK)
+                       if (IS_ENABLED(CONFIG_HAVE_MEMBLOCK))
                                pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
                        continue;
                }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
