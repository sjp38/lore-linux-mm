Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 83FB56B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 08:52:26 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id n12so169766wgh.21
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 05:52:25 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
        by mx.google.com with ESMTPS id mw16si8921526wic.65.2014.08.27.05.52.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 05:52:24 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so5773076wiv.5
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 05:52:24 -0700 (PDT)
Date: Wed, 27 Aug 2014 13:52:21 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATH V2 2/6] arm: mm: Introduce special ptes for LPAE
Message-ID: <20140827125220.GB7765@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-3-git-send-email-steve.capper@linaro.org>
 <20140827104653.GG6968@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827104653.GG6968@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Aug 27, 2014 at 11:46:53AM +0100, Catalin Marinas wrote:
> On Thu, Aug 21, 2014 at 04:43:28PM +0100, Steve Capper wrote:
> > We need a mechanism to tag ptes as being special, this indicates that
> > no attempt should be made to access the underlying struct page *
> > associated with the pte. This is used by the fast_gup when operating on
> > ptes as it has no means to access VMAs (that also contain this
> > information) locklessly.
> > 
> > The L_PTE_SPECIAL bit is already allocated for LPAE, this patch modifies
> > pte_special and pte_mkspecial to make use of it, and defines
> > __HAVE_ARCH_PTE_SPECIAL.
> > 
> > This patch also excludes special ptes from the icache/dcache sync logic.
> > 
> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks Catalin,
I've added this to the patch.
-- 
Steve

> --
> To unsubscribe from this list: send the line "unsubscribe linux-arch" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
