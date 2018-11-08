Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 150586B05FC
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 09:21:46 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b8-v6so18895889pls.11
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 06:21:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k16-v6sor4767014pll.45.2018.11.08.06.21.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 06:21:44 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Thu, 8 Nov 2018 23:21:25 +0900
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181108142125.GA445@tigerII.localdomain>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <20181108115310.rf7htdyyocaowbdk@pathway.suse.cz>
 <20181108124413.GB30440@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108124413.GB30440@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (11/08/18 21:44), Sergey Senozhatsky wrote:
> 
> If lockdep and OOM people will ACK buffered printk transition in
> its current form, then we can go ahead.

That printk_safe approach in lockdep, BTW, does not change (convert)
any printk-s within lockdep, thus Peter's earlycon should not be
affected. So Peter will have earlycon working, syzbot folks will have
buffered lockdep print outs.

	-ss
