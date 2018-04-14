Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB6E6B0003
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 22:35:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e9so5775813pfn.16
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 19:35:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x32-v6sor3423928pld.43.2018.04.13.19.35.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 19:35:21 -0700 (PDT)
Date: Sat, 14 Apr 2018 11:35:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180414023516.GA17806@tigerII.localdomain>
References: <20180413124704.19335-1-pmladek@suse.com>
 <20180413101233.0792ebf0@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413101233.0792ebf0@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org

On (04/13/18 10:12), Steven Rostedt wrote:
> 
> > The interval is set to one hour. It is rather arbitrary selected time.
> > It is supposed to be a compromise between never print these messages,
> > do not lockup the machine, do not fill the entire buffer too quickly,
> > and get information if something changes over time.
> 
> 
> I think an hour is incredibly long. We only allow 100 lines per hour for
> printks happening inside another printk?
> 
> I think 5 minutes (at most) would probably be plenty. One minute may be
> good enough.

Besides 100 lines is absolutely not enough for any real lockdep splat.
My call would be - up to 1000 lines in a 1 minute interval.

	-ss
