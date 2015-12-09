Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF57B6B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 10:03:06 -0500 (EST)
Received: by wmec201 with SMTP id c201so264901543wme.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 07:03:06 -0800 (PST)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id wp8si11869138wjb.0.2015.12.09.07.03.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 07:03:05 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 7920998D00
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 15:03:04 +0000 (UTC)
Date: Wed, 9 Dec 2015 15:03:02 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] MIPS: fix DMA contiguous allocation
Message-ID: <20151209150302.GB15910@techsingularity.net>
References: <1449672845-2196-1-git-send-email-qais.yousef@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1449672845-2196-1-git-send-email-qais.yousef@imgtec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qais Yousef <qais.yousef@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org, akpm@linux-foundation.org

On Wed, Dec 09, 2015 at 02:54:05PM +0000, Qais Yousef wrote:
> Recent changes to how GFP_ATOMIC is defined seems to have broken the condition
> to use mips_alloc_from_contiguous() in mips_dma_alloc_coherent().
> 
> I couldn't bottom out the exact change but I think it's this one
> 
> d0164adc89f6 (mm, page_alloc: distinguish between being unable to sleep,
> unwilling to sleep and avoiding waking kswapd)
> 
> From what I see GFP_ATOMIC has multiple bits set and the check for !(gfp
> & GFP_ATOMIC) isn't enough.
> 
> The reason behind this condition is to check whether we can potentially do
> a sleeping memory allocation. Use gfpflags_allow_blocking() instead which
> should be more robust.
> 
> Signed-off-by: Qais Yousef <qais.yousef@imgtec.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
