Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3C46B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 04:24:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so8330191wms.7
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 01:24:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m70si1604936wmg.143.2016.12.15.01.24.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 01:24:48 -0800 (PST)
From: Andreas Schwab <schwab@suse.de>
Subject: Re: jemalloc testsuite stalls in memset
References: <mvmmvfy37g1.fsf@hawking.suse.de> <20161214235031.GA2912@bbox>
Date: Thu, 15 Dec 2016 10:24:47 +0100
In-Reply-To: <20161214235031.GA2912@bbox> (Minchan Kim's message of "Thu, 15
	Dec 2016 08:50:31 +0900")
Message-ID: <mvm4m2535pc.fsf@hawking.suse.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mbrugger@suse.de, linux-mm@kvack.org, Jason Evans <je@fb.com>

On Dez 15 2016, Minchan Kim <minchan@kernel.org> wrote:

> You mean program itself access the address(ie, 0xffffb7400000) is hang
> while access the address from the debugger is OK?

Yes.

> Can you reproduce it easily?

100%

> Did you test it in real machine or qemu on x86?

Both real and kvm.

> Could you show me how I can reproduce it?

Just run make check.

> I want to test it in x86 machine, first of all.
> Unfortunately, I don't have any aarch64 platform now so maybe I have to
> run it on qemu on x86 until I can set up aarch64 platform if it is reproducible
> on real machine only.
>
>> 
>> The kernel has been configured with transparent hugepages.
>> 
>> CONFIG_TRANSPARENT_HUGEPAGE=y
>> CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
>> # CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
>> CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
>
> What's the exact kernel version?

Anything >= your commit.

> I don't think it's HUGE_PAGECACHE problem but to narrow down the scope,
> could you test it without CONFIG_TRANSPARENT_HUGE_PAGECACHE?

That cannot be deselected.

Andreas.

-- 
Andreas Schwab, SUSE Labs, schwab@suse.de
GPG Key fingerprint = 0196 BAD8 1CE9 1970 F4BE  1748 E4D4 88E3 0EEA B9D7
"And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
