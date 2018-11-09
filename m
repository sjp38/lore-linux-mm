Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59D1C6B06FD
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 09:43:01 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id g24-v6so1608823pfi.23
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 06:43:01 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q14si7209471pgq.197.2018.11.09.06.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 06:42:59 -0800 (PST)
Date: Fri, 9 Nov 2018 09:42:56 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181109094256.147a5de0@gandalf.local.home>
In-Reply-To: <CAHk-=wizC7pn=+F5kNWaz65hb=meyVGLgkGGfZ82mNXp=-E=tQ@mail.gmail.com>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
	<20181108044510.GC2343@jagdpanzerIV>
	<9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
	<20181109061204.GC599@jagdpanzerIV>
	<CAHk-=wizC7pn=+F5kNWaz65hb=meyVGLgkGGfZ82mNXp=-E=tQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: sergey.senozhatsky.work@gmail.com, penguin-kernel@i-love.sakura.ne.jp, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, dvyukov@google.com, glider@google.com, fengguang.wu@intel.com, jpoimboe@redhat.com, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri, 9 Nov 2018 08:08:13 -0600
Linus Torvalds <torvalds@linux-foundation.org> wrote:

>  You guys seem to be talking it out
> ok.

Do your new filters not only remove words, but also add text?

  ;-)

-- Steve
