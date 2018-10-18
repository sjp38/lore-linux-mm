Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA19E6B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 04:13:58 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t9-v6so22895084plq.15
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 01:13:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g80-v6sor10466361pfd.36.2018.10.18.01.13.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 01:13:57 -0700 (PDT)
Date: Thu, 18 Oct 2018 17:13:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181018081352.GA438@jagdpanzerIV>
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
 <20181018061018.GB650@jagdpanzerIV>
 <20181018075611.GY18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018075611.GY18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On (10/18/18 09:56), Michal Hocko wrote:
> On Thu 18-10-18 15:10:18, Sergey Senozhatsky wrote:
> [...]
> > and let's hear from MM people what they can suggest.
> > 
> > Michal, Andrew, Johannes, any thoughts?
> 
> I have already stated my position. Let's not reinvent the wheel and use
> the standard printk throttling. If there are cases where oom reports
> cause more harm than good I am open to add a knob to allow disabling it
> altogether (it can be even fine grained one to control whether to dump
> show_mem, task_list etc.).

A knob might do.
As well as /proc/sys/kernel/printk tweaks, probably. One can even add
echo "a b c d" > /proc/sys/kernel/printk to .bashrc and adjust printk
console levels on login and rollback to old values in .bash_logout
May be.

> But please let's stop this dubious one-off approaches.

OK. Well, I'm not proposing anything actually. I didn't even
realize until recently that Tetsuo was talking about "user
interaction" problem; I thought that his problem was stalled
RCU.

	-ss
