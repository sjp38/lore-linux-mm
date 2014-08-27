Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC446B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 09:01:18 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so174212wgh.15
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:01:17 -0700 (PDT)
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
        by mx.google.com with ESMTPS id s4si441606wjw.122.2014.08.27.06.01.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 06:01:17 -0700 (PDT)
Received: by mail-we0-f170.google.com with SMTP id w62so185820wes.15
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:01:15 -0700 (PDT)
Date: Wed, 27 Aug 2014 14:01:08 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATH V2 4/6] arm: mm: Enable RCU fast_gup
Message-ID: <20140827130107.GA8210@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-5-git-send-email-steve.capper@linaro.org>
 <20140827115137.GK6968@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827115137.GK6968@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Aug 27, 2014 at 12:51:37PM +0100, Catalin Marinas wrote:
> On Thu, Aug 21, 2014 at 04:43:30PM +0100, Steve Capper wrote:
> > Activate the RCU fast_gup for ARM. We also need to force THP splits to
> > broadcast an IPI s.t. we block in the fast_gup page walker. As THP
> > splits are comparatively rare, this should not lead to a noticeable
> > performance degradation.
> > 
> > Some pre-requisite functions pud_write and pud_page are also added.
> > 
> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
