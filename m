Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C54F6B0289
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:34:48 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id p202so7671043iod.18
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:34:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c38sor1490156iod.34.2018.01.16.11.34.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 11:34:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
References: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
 <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp> <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 16 Jan 2018 11:34:46 -0800
Message-ID: <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On Tue, Jan 16, 2018 at 9:33 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> Since I got a faster reproducer, I tried full bisection between 4.11 and 4.12-rc1.
> But I have no idea why bisection arrives at c0332694903a37cf.

I don't think your reproducer is 100% reliable.

And bisection is great because it's very aggressive and optimal when
it comes to testing. But that also implies that if *any* of the
good/bad choices were incorrect, then the end result is pure garbage
and isn't even *close* to the right commit.

> It turned out that CONFIG_FLATMEM was irrelevant. I just did not hit it.

So have you actually been able to see the problem with FLATMEM, or is
this based on the bisect? Because I really think the bisect is pretty
much guaranteed to be wrong.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
