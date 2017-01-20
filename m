Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78E1B6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 08:35:29 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so5576808wmv.5
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:35:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a206si3502389wmh.55.2017.01.20.05.35.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 05:35:28 -0800 (PST)
Subject: Re: [PATCH 3/3] mm: wire up GFP flag passing in
 dma_alloc_from_contiguous
References: <20170119170707.31741-1-l.stach@pengutronix.de>
 <20170119170707.31741-3-l.stach@pengutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <139e94c3-4d03-de35-0c91-217c73c0f5f2@suse.cz>
Date: Fri, 20 Jan 2017 14:35:26 +0100
MIME-Version: 1.0
In-Reply-To: <20170119170707.31741-3-l.stach@pengutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alexander Graf <agraf@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-xtensa@linux-xtensa.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On 01/19/2017 06:07 PM, Lucas Stach wrote:
> The callers of the DMA alloc functions already provide the proper
> context GFP flags. Make sure to pass them through to the CMA
> allocator, to make the CMA compaction context aware.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
