Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0C7F6B0269
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 07:48:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e6-v6so3320981pge.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 04:48:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u2-v6sor16747333plq.31.2018.10.10.04.48.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 04:48:49 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Wed, 10 Oct 2018 20:48:33 +0900
Subject: Re: INFO: rcu detected stall in shmem_fault
Message-ID: <20181010114833.GB3949@tigerII.localdomain>
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <20181010085945.GC5873@dhcp22.suse.cz>
 <e72f799e-0634-f958-1af0-291f8577f4e8@i-love.sakura.ne.jp>
 <20181010113500.GH5873@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010113500.GH5873@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>

On (10/10/18 13:35), Michal Hocko wrote:
> > Just flooding out of memory messages can trigger RCU stall problems.
> > For example, a severe skbuff_head_cache or kmalloc-512 leak bug is causing
> 
> [...]
> 
> Quite some of them, indeed! I guess we want to rate limit the output.
> What about the following?

A bit unrelated, but while we are at it:

  I like it when we rate-limit printk-s that lookup the system.
But it seems that default rate-limit values are not always good enough,
DEFAULT_RATELIMIT_INTERVAL / DEFAULT_RATELIMIT_BURST can still be too
verbose. For instance, when we have a very slow IPMI emulated serial
console -- e.g. baud rate at 57600. DEFAULT_RATELIMIT_INTERVAL and
DEFAULT_RATELIMIT_BURST can add new OOM headers and backtraces faster
than we evict them.

Does it sound reasonable enough to use larger than default rate-limits
for printk-s in OOM print-outs? OOM reports tend to be somewhat large
and the reported numbers are not always *very* unique.

What do you think?

	-ss
