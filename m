Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFCB66B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:17:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k66-v6so4928810pga.21
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:17:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y7-v6sor15409068pfi.44.2018.10.10.18.17.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 18:17:35 -0700 (PDT)
Date: Thu, 11 Oct 2018 10:17:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: INFO: rcu detected stall in shmem_fault
Message-ID: <20181011011730.GA728@jagdpanzerIV>
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <20181010085945.GC5873@dhcp22.suse.cz>
 <e72f799e-0634-f958-1af0-291f8577f4e8@i-love.sakura.ne.jp>
 <20181010113500.GH5873@dhcp22.suse.cz>
 <20181010114833.GB3949@tigerII.localdomain>
 <20181010122539.GI5873@dhcp22.suse.cz>
 <CACT4Y+ZfVdeB-WNeLCWJvTHNeCUtR3r1R+3Qjv9XjZXPxaV2WA@mail.gmail.com>
 <CACT4Y+bqJeKum7jessccWQF+4BmabnVy48aqHEOypioKwQAMTQ@mail.gmail.com>
 <b7727ff0-b34f-25a2-b9e7-56e70d9349c4@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b7727ff0-b34f-25a2-b9e7-56e70d9349c4@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yang Shi <yang.s@alibaba-inc.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>

On (10/10/18 22:10), Tetsuo Handa wrote:
> >> I've found at least 1 place that uses DEFAULT_RATELIMIT_INTERVAL*10:
> >> https://elixir.bootlin.com/linux/latest/source/fs/btrfs/extent-tree.c#L8365
> >> Probably we need something similar here.
> 
> Since printk() is a significantly CPU consuming operation, I think that what
> we need to guarantee is interval between the end of an OOM killer messages
> and the beginning of next OOM killer messages is large enough. For example,
> setup a timer with 5 seconds timeout upon the end of an OOM killer messages
> and check whether the timer already fired upon the beginning of next OOM killer
> messages.

Hmm, there is no way to make sure that previous OOM report made it to
consoles. So maybe timer approach will be as good as rate-limiting.

	-ss
