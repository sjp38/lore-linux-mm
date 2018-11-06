Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57D226B031F
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 07:57:58 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m45-v6so7603082edc.2
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 04:57:58 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f26-v6si697707edm.355.2018.11.06.04.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 04:57:56 -0800 (PST)
Date: Tue, 6 Nov 2018 13:57:53 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181106125753.nhuztqefadglbvec@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181102133629.GN3178@hirez.programming.kicks-ass.net>
 <20181106083856.lhmibz6vrgtkqsj7@pathway.suse.cz>
 <20181106090544.GA516@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106090544.GA516@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

On Tue 2018-11-06 18:05:44, Sergey Senozhatsky wrote:
> On (11/06/18 09:38), Petr Mladek wrote:
> > 
> > If you would want to avoid buffering, you could set the number
> > of buffers to zero. Then it would always fallback to
> > the direct printk().

This comment was a hint for Peter and his workarounds. He ignores most
of printk() code and writes messages directly to the serial console.


> This printk-fallback makes me wonder if 'cont' really can ever go away.
> We would totally break cont printk-s that trapped into printk-fallback;
> as opposed to current sometimes-cont-works-just-fine.

It could break things totally only when the new approach completely
fails. I you have any doubts or suggestions then please comment on
the patch adding the API.

Best Regards,
Petr
