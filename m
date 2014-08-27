Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C0B9A6B0039
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 09:08:34 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so405995wiv.13
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:08:34 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
        by mx.google.com with ESMTPS id l9si510972wjf.107.2014.08.27.06.08.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 06:08:29 -0700 (PDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so409760wiw.6
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:08:28 -0700 (PDT)
Date: Wed, 27 Aug 2014 14:08:25 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATH V2 5/6] arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
Message-ID: <20140827130824.GB8210@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-6-git-send-email-steve.capper@linaro.org>
 <20140827104840.GH6968@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827104840.GH6968@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Aug 27, 2014 at 11:48:41AM +0100, Catalin Marinas wrote:
> On Thu, Aug 21, 2014 at 04:43:31PM +0100, Steve Capper wrote:
> > In order to implement fast_get_user_pages we need to ensure that the
> > page table walker is protected from page table pages being freed from
> > under it.
> > 
> > This patch enables HAVE_RCU_TABLE_FREE, any page table pages belonging
> > to address spaces with multiple users will be call_rcu_sched freed.
> > Meaning that disabling interrupts will block the free and protect the
> > fast gup page walker.
> > 
> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> 
> I'm happy to take this patch independently of this series. But if the
> whole series goes in via some other tree (mm):
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks. If patch #1 looks okay to the mm folks, I'm hoping this patch
can be merged via the same tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
