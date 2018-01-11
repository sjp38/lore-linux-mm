Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E42B76B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 04:34:42 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r63so1122433wmb.9
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 01:34:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q202si322841wme.252.2018.01.11.01.34.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 01:34:41 -0800 (PST)
Date: Thu, 11 Jan 2018 10:34:35 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111093435.GA24497@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111045817.GA494@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Thu 2018-01-11 13:58:17, Sergey Senozhatsky wrote:
> On (01/10/18 13:05), Steven Rostedt wrote:
> > The solution is simple, everyone at KS agreed with it, there should be
> > no controversy here.
> 
> frankly speaking, that's not what I recall ;)

To be honest, I do not longer remember the details. I think that
nobody was really against that solution. Of course, there were
doubts and other proposals.

I think that I was actually the most sceptical guy there. I would
split my old doubts into three areas:

      + new possible deadlocks
            -> I was wrong

      + did not fully prevent softlockups
            -> no real life example in hands

      + looked tricky and complex
	    -> like many other new things

You see that I have changed my mind and decided to give this solution
a chance.

 
> [..]
> > My printk solution is solid, with no risk of regressions of current
> > printk usages.
> 
> except that handing off a console_sem to atomic task when there
> is   O(logbuf) > watchdog_thresh   is a regression, basically...
> it is what it is.

How this could be a regression? Is not the victim that handles
other printk's random? What protected the atomic task to
handle the other printks before this patch?

Or do you have a system that started to suffer from softlockups
with this patchset and did not do this before?
 
> 
> > If anything, I'll pull theses patches myself, and push them to Linus
> > directly
> 
> lovely.

Do you know about any system where this patch made the softlockup
deterministically or statistically more likely, please?

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
