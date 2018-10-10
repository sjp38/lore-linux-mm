Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E08EB6B026E
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:25:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h24-v6so3077625eda.10
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:25:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e44-v6si14794407edd.247.2018.10.10.05.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 05:25:42 -0700 (PDT)
Date: Wed, 10 Oct 2018 14:25:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu detected stall in shmem_fault
Message-ID: <20181010122539.GI5873@dhcp22.suse.cz>
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <20181010085945.GC5873@dhcp22.suse.cz>
 <e72f799e-0634-f958-1af0-291f8577f4e8@i-love.sakura.ne.jp>
 <20181010113500.GH5873@dhcp22.suse.cz>
 <20181010114833.GB3949@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010114833.GB3949@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>

On Wed 10-10-18 20:48:33, Sergey Senozhatsky wrote:
> On (10/10/18 13:35), Michal Hocko wrote:
> > > Just flooding out of memory messages can trigger RCU stall problems.
> > > For example, a severe skbuff_head_cache or kmalloc-512 leak bug is causing
> > 
> > [...]
> > 
> > Quite some of them, indeed! I guess we want to rate limit the output.
> > What about the following?
> 
> A bit unrelated, but while we are at it:
> 
>   I like it when we rate-limit printk-s that lookup the system.
> But it seems that default rate-limit values are not always good enough,
> DEFAULT_RATELIMIT_INTERVAL / DEFAULT_RATELIMIT_BURST can still be too
> verbose. For instance, when we have a very slow IPMI emulated serial
> console -- e.g. baud rate at 57600. DEFAULT_RATELIMIT_INTERVAL and
> DEFAULT_RATELIMIT_BURST can add new OOM headers and backtraces faster
> than we evict them.
> 
> Does it sound reasonable enough to use larger than default rate-limits
> for printk-s in OOM print-outs? OOM reports tend to be somewhat large
> and the reported numbers are not always *very* unique.
> 
> What do you think?

I do not really care about the current inerval/burst values. This change
should be done seprately and ideally with some numbers.
-- 
Michal Hocko
SUSE Labs
