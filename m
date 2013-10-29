Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CE0616B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 15:50:10 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so507811pab.6
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 12:50:10 -0700 (PDT)
Received: from psmtp.com ([74.125.245.105])
        by mx.google.com with SMTP id yj4si16714336pac.21.2013.10.29.12.50.06
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 12:50:07 -0700 (PDT)
Date: Tue, 29 Oct 2013 19:49:56 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 0/2] Implement get_user_pages_fast for ARM
Message-ID: <20131029194956.GC24556@mudshark.cambridge.arm.com>
References: <1382101634-4723-1-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382101634-4723-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoffer Dall <christoffer.dall@linaro.org>, Russell King <linux@arm.linux.org.uk>, Zi Shen Lim <zishen.lim@linaro.org>, "patches@linaro.org" <patches@linaro.org>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>

On Fri, Oct 18, 2013 at 02:07:11PM +0100, Steve Capper wrote:
> This patch series implements get_user_pages_fast on ARM. Unlike other
> architectures, we do not use IPIs/disabled IRQs as a blocking
> mechanism to protect the page table walker. Instead an atomic counter
> is used to indicate how many fast gup walkers are active on an address
> space, and any code that would cause them problems (THP splitting or
> code that could free a page table page) spins on positive values of
> this counter.

Curious: did you try benchmarking the two schemes? Whilst I expect this
algorithm to be better on ARM, exclusive memory accesses aren't free and
we're adding code to the fast path.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
