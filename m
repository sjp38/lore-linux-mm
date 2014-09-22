Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9FA6B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 05:29:03 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id em10so2508799wid.5
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 02:29:02 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id dk6si7670269wib.44.2014.09.22.02.29.01
        for <linux-mm@kvack.org>;
        Mon, 22 Sep 2014 02:29:01 -0700 (PDT)
Date: Mon, 22 Sep 2014 10:28:38 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH V3 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-ID: <20140922092838.GC25809@arm.com>
References: <1409237107-24228-1-git-send-email-steve.capper@linaro.org>
 <20140828152320.GN22580@arm.com>
 <CAPvkgC0YVhPEBqbWSDnGyZBUn3+8Kv7-yx1-_n0Jx+giKzOqmw@mail.gmail.com>
 <20140908090626.GA14634@linaro.org>
 <20140919182808.GA22622@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140919182808.GA22622@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>, "hughd@google.com" <hughd@google.com>

On Fri, Sep 19, 2014 at 07:28:09PM +0100, Steve Capper wrote:
> Apologies for being a pest, but we're really keen to get this into 3.18,
> as it fixes a THP problem with arm/arm64.
> 
> I need mm folk to either ack or flame the first patch in the series in
> order to proceed. (All the patches in the series have been
> acked/reviewed, but not by any mm folk.):
>  [PATCH V3 1/6] mm: Introduce a general RCU get_user_pages_fast.
> 
> If it puts people's minds at rest regarding the testing...
> On top of the ltp tests, and futex tests, we also ran these patches on
> the arm64 Debian buildd's. With THP set to always, just under 8000
> Debian packages have been built (and unit tested) without any kernel
> issues for arm64.

Yes, please. It would be great if somebody can take these into an -mm tree
and/or provide an ack so that we can queue them via the arm64 tree instead.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
