Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id F1CCA6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 10:43:04 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id l18so323160wgh.25
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:43:04 -0700 (PDT)
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
        by mx.google.com with ESMTPS id eg6si9410455wic.96.2014.08.27.07.42.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 07:42:46 -0700 (PDT)
Received: by mail-we0-f169.google.com with SMTP id u56so336964wes.14
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:42:46 -0700 (PDT)
Date: Wed, 27 Aug 2014 15:42:36 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATH V2 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20140827144235.GA10456@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-2-git-send-email-steve.capper@linaro.org>
 <20140827142801.GA13850@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827142801.GA13850@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Aug 27, 2014 at 03:28:01PM +0100, Catalin Marinas wrote:
> On Thu, Aug 21, 2014 at 04:43:27PM +0100, Steve Capper wrote:
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 886db21..6a4d764 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
> >  config HAVE_MEMBLOCK_PHYS_MAP
> >  	boolean
> >  
> > +config HAVE_RCU_GUP
> > +	boolean
> 
> Minor detail, maybe HAVE_GENERIC_RCU_GUP to avoid confusion.

Yeah, that does look better, I'll amend the series accordingly.

> 
> Otherwise the patch looks fine to me.
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks Catalin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
