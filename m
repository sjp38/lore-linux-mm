Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 80F846B003D
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 21:09:49 -0400 (EDT)
Date: Wed, 27 Mar 2013 10:09:47 +0900
From: Minchan Kim <minchan.kim@lge.com>
Subject: Re: [PATCH] staging: zsmalloc: Fix link error on ARM
Message-ID: <20130327010947.GA2710@blaptop>
References: <1364337232-3513-1-git-send-email-joro@8bytes.org>
 <20130327000552.GA13283@blaptop>
 <20130327004314.GH30540@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130327004314.GH30540@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 27, 2013 at 01:43:14AM +0100, Joerg Roedel wrote:
> On Wed, Mar 27, 2013 at 09:05:52AM +0900, Minchan Kim wrote:
> > And please Cc stable.
> 
> Okay, here it is. The result is compile-tested.
> 
> Changes since v1:
> 
> * Remove the module-export for unmap_kernel_range and make zsmalloc
>   built-in instead
> 
> Here is the patch:
> 
> >From 2b70502720b36909f9f39bdf27be21321a219c31 Mon Sep 17 00:00:00 2001
> From: Joerg Roedel <joro@8bytes.org>
> Date: Tue, 26 Mar 2013 23:24:22 +0100
> Subject: [PATCH v2] staging: zsmalloc: Fix link error on ARM
> 
> Testing the arm chromebook config against the upstream
> kernel produces a linker error for the zsmalloc module from
> staging. The symbol flush_tlb_kernel_range is not available
> there. Fix this by removing the reimplementation of
> unmap_kernel_range in the zsmalloc module and using the
> function directly. The unmap_kernel_range function is not
> usable by modules, so also disallow building the driver as a
> module for now.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Joerg Roedel <joro@8bytes.org>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
