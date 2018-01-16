Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70AD26B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 03:37:43 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b186so3289683wmf.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 00:37:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 49sor698788wrz.85.2018.01.16.00.37.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 00:37:42 -0800 (PST)
Date: Tue, 16 Jan 2018 09:37:39 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180116083739.irw62va5kpc62cvr@gmail.com>
References: <201801142054.FAD95378.LVOOFQJOFtMFSH@I-love.SAKURA.ne.jp>
 <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <7f100b0f-3588-be25-41f6-a0e4dde27916@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f100b0f-3588-be25-41f6-a0e4dde27916@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> Did anyone else notice the
> 
> 	[   31.068198]  ? vmalloc_sync_all+0x150/0x150
> 
> present in a bunch of the stack traces?  That should be pretty uncommon.

I thikn that's pretty unusual:

>  Is it just part of the normal do_page_fault() stack and the stack
> dumper picks up on it?

No, it should only be called by register_die_notifier(), which is not part of the 
regular stack dump, AFAICS.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
