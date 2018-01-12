Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64AA76B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 20:42:05 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w125so5574566itf.0
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 17:42:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o124sor1189130ith.113.2018.01.11.17.42.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 17:42:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801120131.w0C1VJUN034283@www262.sakura.ne.jp>
References: <201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
 <20180111142148.GD1732@dhcp22.suse.cz> <201801120131.w0C1VJUN034283@www262.sakura.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 11 Jan 2018 17:42:03 -0800
Message-ID: <CA+55aFx4pH4odYDfuGemm5TK-CS4E8pL_ipHCVzVBmsQkyWp1Q@mail.gmail.com>
Subject: Re: [mm 4.15-rc7] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Jan 11, 2018 at 5:31 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> Thus, I suspect that somewhere is confusing HighMem pages and !HighMem pages.

Hmm. I can't even imagine how you'd do that.

Sure, if you take page_address() to get a kmap'ed linear address, and
then feed that linear address back to virt_to_page(), you'd certainly
get a crazy page. But that would be insane.. I don't see how you'd do
that.

Hmm. Do you have CONFIG_DEBUG_VIRTUAL enabled? That should catch at
least the above case, it should enable a debugging version of
__virt_to_phys() and use it.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
