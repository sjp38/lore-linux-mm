Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3C1A56B00CD
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 08:41:38 -0400 (EDT)
Date: Tue, 12 Oct 2010 20:41:35 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] HWPOISON: Implement hwpoison-on-free for soft offlining
Message-ID: <20101012124135.GA15163@localhost>
References: <1286402951-1881-1-git-send-email-andi@firstfloor.org>
 <1286402951-1881-2-git-send-email-andi@firstfloor.org>
 <20101012122647.GA14208@localhost>
 <4CB45672.7020206@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CB45672.7020206@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> >> +		if (PageHWPoisonOnFree(page))
> >> +			hwpoison_page_on_free(page);
> > hwpoison_page_on_free() seems to be undefined when
> > CONFIG_HWPOISON_ON_FREE is not defined.
> 
> Yes, but I rely on the compiler never generating the call in this case 
> because
> the test is zero.
> 
> It would fail on a unoptimized build, but the kernel doesn't support 
> that anyways.

Fair enough.

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

> Thanks for the review.

:)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
