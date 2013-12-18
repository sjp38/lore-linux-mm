Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 88B0F6B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 05:24:16 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id w62so7367060wes.31
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 02:24:15 -0800 (PST)
Received: from mail-ea0-x234.google.com (mail-ea0-x234.google.com [2a00:1450:4013:c01::234])
        by mx.google.com with ESMTPS id wd4si8276542wjc.61.2013.12.18.02.24.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 02:24:15 -0800 (PST)
Received: by mail-ea0-f180.google.com with SMTP id f15so3415155eak.25
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 02:24:15 -0800 (PST)
Date: Wed, 18 Dec 2013 11:24:12 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131218102412.GC20360@gmail.com>
References: <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
 <20131216134449.GA3034@gmail.com>
 <20131217092124.GV11295@suse.de>
 <20131217110051.GA27701@gmail.com>
 <20131217143253.GB11295@suse.de>
 <20131217144214.GA12370@gmail.com>
 <20131217175441.GI11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217175441.GI11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Mel Gorman <mgorman@suse.de> wrote:

> > Thanks again for going through all this. Tracking multi-commit 
> > performance regressions across 1.5 years worth of commits is 
> > generally very hard. Does your testing effort comes from 
> > enterprise Linux QA testing, or did you ran into this problem 
> > accidentally?
> 
> It does not come from enterprise Linux QA testing but it's motivated 
> by it. I want to catch as many "obvious" performance bugs before 
> they do as it saves time and stress in the long run. To assist that, 
> I setup continual performance regression testing and ebizzy was 
> included in the first report I opened. [...]

Neat!

> [...]  It makes me worry what the rest of the reports contain.

It will be full with reports of phenomenal speedups!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
