Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9C0B6B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 03:56:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e7-v6so17690192edb.23
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 00:56:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b91-v6si16604577edf.286.2018.10.18.00.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 00:56:14 -0700 (PDT)
Date: Thu, 18 Oct 2018 09:56:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181018075611.GY18839@dhcp22.suse.cz>
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
 <20181018061018.GB650@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018061018.GB650@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On Thu 18-10-18 15:10:18, Sergey Senozhatsky wrote:
[...]
> and let's hear from MM people what they can suggest.
> 
> Michal, Andrew, Johannes, any thoughts?

I have already stated my position. Let's not reinvent the wheel and use
the standard printk throttling. If there are cases where oom reports
cause more harm than good I am open to add a knob to allow disabling it
altogether (it can be even fine grained one to control whether to dump
show_mem, task_list etc.).

But please let's stop this dubious one-off approaches.
-- 
Michal Hocko
SUSE Labs
