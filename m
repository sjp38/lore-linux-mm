Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE286B012A
	for <linux-mm@kvack.org>; Mon, 25 May 2015 16:30:19 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so58908916wic.1
        for <linux-mm@kvack.org>; Mon, 25 May 2015 13:30:19 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id eb8si14313340wib.36.2015.05.25.13.30.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 13:30:18 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Date: Mon, 25 May 2015 22:29:40 +0200
Message-ID: <5601369.jDWtB6nFJC@wuerfel>
In-Reply-To: <F68D2983-226C-4704-A1E0-E79C9425B822@foss.arm.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <B873B881-4972-4524-B1D9-4BB05D7248A4@gmail.com> <F68D2983-226C-4704-A1E0-E79C9425B822@foss.arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@foss.arm.com>
Cc: Jungseok Lee <jungseoklee85@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, "barami97@gmail.com" <barami97@gmail.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Monday 25 May 2015 19:47:15 Catalin Marinas wrote:
> On 25 May 2015, at 13:01, Jungseok Lee <jungseoklee85@gmail.com> wrote:
> 
> >> Could the stack size be reduced to 8KB perhaps?
> > 
> > I guess probably not.
> > 
> > A commit, 845ad05e, says that 8KB is not enough to cover SpecWeb benchmark.
> 
> We could go back to 8KB stacks if we implement support for separate IRQ 
> stack on arm64. It's not too complicated, we would have to use SP0 for (kernel) threads 
> and SP1 for IRQ handlers.

I think most architectures that see a lot of benchmarks have moved to
irqstacks at some point, that definitely sounds like a useful idea,
even if the implementation turns out to be a bit more tricky than
what you describe.

There are a lot of workloads that would benefit from having lower
per-thread memory cost.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
