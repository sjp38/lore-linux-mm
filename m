Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E17B6B1DAE
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 21:28:47 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s22so310663pgv.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 18:28:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9-v6sor51672638pfd.63.2018.11.19.18.28.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 18:28:46 -0800 (PST)
Date: Tue, 20 Nov 2018 11:28:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: request for 4.14-stable: fd5f7cde1b85 ("printk: Never set
 console_may_schedule in console_trylock()")
Message-ID: <20181120022841.GB4231@jagdpanzerIV>
References: <20181111202045.vocb3dthuquf7h2y@debian>
 <20181119151807.GE5340@kroah.com>
 <20181120022315.GA4231@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120022315.GA4231@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>, stable@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (11/20/18 11:23), Sergey Senozhatsky wrote:
> On (11/19/18 16:18), Greg Kroah-Hartman wrote:
> > On Sun, Nov 11, 2018 at 08:20:45PM +0000, Sudip Mukherjee wrote:
> > > Hi Greg,
> > > 
> > > This was not marked for stable but seems it should be in stable.
> > > Please apply to your queue of 4.14-stable.
> > 
> > Now queued up, thanks.
> 
> Very sorry for the late reply!
> 
> Greg, Sudip, the commit in question is known to be controversial

Yikes!! PLEASE *IGNORE MY PREVIOUS EMAIL*!


This is a *totally stupid* situation. I, somehow, got completely confused
and looked at the wrong commit ID.

Really sorry!

Yes, backporting fd5f7cde1b85 for stable is OK, no real objections.

	-ss
