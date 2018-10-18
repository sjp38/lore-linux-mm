Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52CD06B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 19:54:34 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 75-v6so2218830pgc.13
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 16:54:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 19-v6sor11995409pgv.22.2018.10.18.16.54.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 16:54:33 -0700 (PDT)
Date: Fri, 19 Oct 2018 08:54:27 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181018235427.GA877@jagdpanzerIV>
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
 <20181018061018.GB650@jagdpanzerIV>
 <20181018075611.GY18839@dhcp22.suse.cz>
 <20181018081352.GA438@jagdpanzerIV>
 <2c2b2820-e6f8-76c8-c431-18f60845b3ab@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2c2b2820-e6f8-76c8-c431-18f60845b3ab@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On (10/18/18 20:58), Tetsuo Handa wrote:
> > 
> > A knob might do.
> > As well as /proc/sys/kernel/printk tweaks, probably. One can even add
> > echo "a b c d" > /proc/sys/kernel/printk to .bashrc and adjust printk
> > console levels on login and rollback to old values in .bash_logout
> > May be.
> 
> That can work for only single login with root user case.
> Not everyone logs into console as root user.

Add sudo ;)

> It is pity that we can't send kernel messages to only selected consoles
> (e.g. all messages are sent to netconsole, but only critical messages are
> sent to local consoles).

OK, that's a fair point. There was a patch from FB, which would allow us
to set a log_level on per-console basis. So the noise goes to heav^W net
console; only critical stuff goes to the serial console (if I recall it
correctly). I'm not sure what happened to that patch, it was a while ago.
I'll try to find that out.

[..]
> That boils down to a "user interaction" problem.
> Not limiting
> 
>   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
>   "Out of memory and no killable processes...\n"
> 
> is very annoying.
> 
> And I really can't understand why Michal thinks "handling this requirement" as
> "make the code more complex than necessary and squash different things together".

Michal is trying very hard to address the problem in a reasonable way.
The problem you are talking about is not MM specific. You can have a
faulty SCSI device, corrupted FS, and so and on.

	-ss
