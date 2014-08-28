Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id BD9FA6B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 11:23:36 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id m20so924616qcx.7
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 08:23:36 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id b6si6094384qar.9.2014.08.28.08.23.31
        for <linux-mm@kvack.org>;
        Thu, 28 Aug 2014 08:23:36 -0700 (PDT)
Date: Thu, 28 Aug 2014 16:23:20 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH V3 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-ID: <20140828152320.GN22580@arm.com>
References: <1409237107-24228-1-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1409237107-24228-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Thu, Aug 28, 2014 at 03:45:01PM +0100, Steve Capper wrote:
> I would like to get this series into 3.18 as it fixes quite a big problem
> with THP on arm and arm64. This series is split into a core mm part, an
> arm part and an arm64 part.
> 
> Could somebody please take patch #1 (if it looks okay)?
> Russell, would you be happy with patches #2, #3, #4? (if we get #1 merged)
> Catalin, would you be happy taking patches #5, #6? (if we get #1 merged)

Pretty sure we're happy to take the arm64 bits once you've got the core
changes sorted out. Failing that, Catalin's acked them so they could go via
an mm tree if it's easier.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
