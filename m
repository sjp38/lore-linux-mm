Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id EC0146B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:49:15 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id x13so22356qcv.8
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 03:49:15 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id l69si7269485qge.95.2014.08.27.03.49.15
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 03:49:15 -0700 (PDT)
Date: Wed, 27 Aug 2014 11:48:41 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATH V2 5/6] arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
Message-ID: <20140827104840.GH6968@arm.com>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-6-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1408635812-31584-6-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Thu, Aug 21, 2014 at 04:43:31PM +0100, Steve Capper wrote:
> In order to implement fast_get_user_pages we need to ensure that the
> page table walker is protected from page table pages being freed from
> under it.
> 
> This patch enables HAVE_RCU_TABLE_FREE, any page table pages belonging
> to address spaces with multiple users will be call_rcu_sched freed.
> Meaning that disabling interrupts will block the free and protect the
> fast gup page walker.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>

I'm happy to take this patch independently of this series. But if the
whole series goes in via some other tree (mm):

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
