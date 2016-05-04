Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 498C46B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 09:53:48 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so49319731wme.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 06:53:48 -0700 (PDT)
Received: from mail.free-electrons.com (down.free-electrons.com. [37.187.137.238])
        by mx.google.com with ESMTP id dc5si5056267wjb.14.2016.05.04.06.53.47
        for <linux-mm@kvack.org>;
        Wed, 04 May 2016 06:53:47 -0700 (PDT)
Date: Wed, 4 May 2016 15:53:45 +0200
From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: kmap_atomic and preemption
Message-ID: <20160504155345.5fdd366e@free-electrons.com>
In-Reply-To: <20160504134729.GP3430@twins.programming.kicks-ass.net>
References: <5729D0F4.9090907@synopsys.com>
	<20160504134729.GP3430@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, Russell King <linux@arm.linux.org.uk>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

Hello,

On Wed, 4 May 2016 15:47:29 +0200, Peter Zijlstra wrote:

> static inline void *kmap_atomic(struct page *page)
> {
> 	preempt_disable();
> 	pagefault_disable();
> 	if (!PageHighMem(page))
> 		return page_address(page);
> 
> 	return __kmap_atomic(page);
> }

This is essentially what has been done on ARM in commit
9ff0bb5ba60638a688a46e93df8c5009896672eb, showing a pretty significant
improvement in network workloads.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
