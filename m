Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09D1D6B06F9
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 09:08:36 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id j131so195066lfg.14
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 06:08:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j3-v6sor4967763ljc.22.2018.11.09.06.08.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 06:08:33 -0800 (PST)
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com. [209.85.167.44])
        by smtp.gmail.com with ESMTPSA id q30sm1450612lfi.94.2018.11.09.06.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 06:08:31 -0800 (PST)
Received: by mail-lf1-f44.google.com with SMTP id q6-v6so1404106lfh.9
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 06:08:30 -0800 (PST)
MIME-Version: 1.0
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz> <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp> <20181109061204.GC599@jagdpanzerIV>
In-Reply-To: <20181109061204.GC599@jagdpanzerIV>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 9 Nov 2018 08:08:13 -0600
Message-ID: <CAHk-=wizC7pn=+F5kNWaz65hb=meyVGLgkGGfZ82mNXp=-E=tQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep messages.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sergey.senozhatsky.work@gmail.com
Cc: penguin-kernel@i-love.sakura.ne.jp, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, dvyukov@google.com, Steven Rostedt <rostedt@goodmis.org>, glider@google.com, fengguang.wu@intel.com, jpoimboe@redhat.com, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri, Nov 9, 2018 at 12:12 AM Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
>
> Dunno. I guess we still haven't heard from Linus because he did quite a good
> job setting up his 'email filters' ;)

Not filters, just long threads that I lurk on.

I don't actually care too much about this - the part I care about is
that when panics etc happen, things go out with a true best effort.

And "best effort" actually means "reality", not "theory". I don't care
one whit for some broken odd serial console that has a lock and
deadlocks if you get a panic just in the right place. I care about the
main printk/tty code doing the right thing, and avoiding the locks
with the scheduler and timers etc. So the timestamping and wakeup code
needing locks - or thinking you can delay things and print them out
later (when no later happens because you're panicing in an NMI) -
*that* is what I care deeply about.

Something like having a line buffering interface for random debugging
messages etc, I just don't get excited about. It just needs to be
simple enough and robust enough. You guys seem to be talking it out
ok.

             Linus
