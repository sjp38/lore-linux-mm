Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40BE16B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 04:37:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id u6-v6so491469eds.10
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 01:37:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f20-v6si570623eds.391.2018.10.23.01.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 01:37:42 -0700 (PDT)
Date: Tue, 23 Oct 2018 10:37:38 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181023083738.o4wo3jxw3xkp3rwx@pathway.suse.cz>
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
 <20181018061018.GB650@jagdpanzerIV>
 <20181018075611.GY18839@dhcp22.suse.cz>
 <20181018081352.GA438@jagdpanzerIV>
 <2c2b2820-e6f8-76c8-c431-18f60845b3ab@i-love.sakura.ne.jp>
 <20181018235427.GA877@jagdpanzerIV>
 <5d472476-7852-f97b-9412-63536dffaa0e@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5d472476-7852-f97b-9412-63536dffaa0e@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On Fri 2018-10-19 19:35:53, Tetsuo Handa wrote:
> On 2018/10/19 8:54, Sergey Senozhatsky wrote:
> > On (10/18/18 20:58), Tetsuo Handa wrote:
> >> That boils down to a "user interaction" problem.
> >> Not limiting
> >>
> >>   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
> >>   "Out of memory and no killable processes...\n"
> >>
> >> is very annoying.
> >>
> >> And I really can't understand why Michal thinks "handling this requirement" as
> >> "make the code more complex than necessary and squash different things together".
> > 
> > Michal is trying very hard to address the problem in a reasonable way.
> 
> OK. But Michal, do we have a reasonable way which can be applied now instead of
> my patch or one of below patches? Just enumerating words like "hackish" or "a mess"
> without YOU ACTUALLY PROPOSE PATCHES will bounce back to YOU.

Michal suggested using ratelimit, the standard solution.

My understanding is that this situation happens when the system is
misconfigured and unusable without manual intervention. If
the user is able to see what the problem is then we are good.

You talk about interactivity but who asked for this?
IMHO, if system ends in OOM situation, it would need to get
restarted in most cases anyway. Then people have a chance
to fix the configuration after the reboot.

Best Regards,
Petr
