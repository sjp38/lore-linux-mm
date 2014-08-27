Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 503A26B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:52:17 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id e89so82989qgf.31
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 04:52:17 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id f98si164931qge.69.2014.08.27.04.52.16
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 04:52:16 -0700 (PDT)
Date: Wed, 27 Aug 2014 12:51:37 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATH V2 4/6] arm: mm: Enable RCU fast_gup
Message-ID: <20140827115137.GK6968@arm.com>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-5-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1408635812-31584-5-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Thu, Aug 21, 2014 at 04:43:30PM +0100, Steve Capper wrote:
> Activate the RCU fast_gup for ARM. We also need to force THP splits to
> broadcast an IPI s.t. we block in the fast_gup page walker. As THP
> splits are comparatively rare, this should not lead to a noticeable
> performance degradation.
> 
> Some pre-requisite functions pud_write and pud_page are also added.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
