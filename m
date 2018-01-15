Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D55C56B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 18:05:23 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id k76so2401743iod.12
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 15:05:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o124sor540019ith.113.2018.01.15.15.05.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 15:05:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
References: <201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
 <20180111142148.GD1732@dhcp22.suse.cz> <201801120131.w0C1VJUN034283@www262.sakura.ne.jp>
 <CA+55aFx4pH4odYDfuGemm5TK-CS4E8pL_ipHCVzVBmsQkyWp1Q@mail.gmail.com>
 <201801122022.IDI35401.VOQOFOMLFSFtHJ@I-love.SAKURA.ne.jp> <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 15 Jan 2018 15:05:20 -0800
Message-ID: <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
Subject: Re: [mm 4.15-rc7] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On Sun, Jan 14, 2018 at 3:54 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> This memory corruption bug occurs even on CONFIG_SMP=n CONFIG_PREEMPT_NONE=y
> kernel. This bug highly depends on timing and thus too difficult to bisect.
> This bug seems to exist at least since Linux 4.8 (judging from the traces, though
> the cause might be different). None of debugging configuration gives me a clue.
> So far only CONFIG_HIGHMEM=y CONFIG_DEBUG_PAGEALLOC=y kernel (with RAM enough to
> use HighMem: zone) seems to hit this bug, but it might be just by chance caused
> by timings. Thus, there is no evidence that 64bit kernels are not affected by
> this bug. But I can't narrow down any more. Thus, I call for developers who can
> narrow down / identify where the memory corruption bug is.

Hmm.

I guess I'm still hung up on the "it does not look like a valid
'struct page *'" thing.

Can you reproduce this with CONFIG_FLATMEM=y instead of CONFIG_SPARSEMEM?

Because if you can, I think we can easily add a few more pfn and
'struct page' validation debug statements. With SPARSEMEM, it gets
pretty complicated because the whole struct page setup is much more
complex.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
