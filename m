Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF3AF800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 23:44:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a2so1629825pgn.7
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 20:44:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor3872071pgc.24.2018.01.23.20.44.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 20:44:54 -0800 (PST)
Date: Wed, 24 Jan 2018 13:44:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180124044448.GC651@jagdpanzerIV>
References: <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180123064023.GA492@jagdpanzerIV>
 <20180123095652.5e14da85@gandalf.local.home>
 <20180123152130.GB429@tigerII.localdomain>
 <20180123104121.2ef96d81@gandalf.local.home>
 <20180123160153.GC429@tigerII.localdomain>
 <20180123112436.0c94bc2e@gandalf.local.home>
 <20180124021034.GA651@jagdpanzerIV>
 <20180123215234.709c845a@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123215234.709c845a@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/23/18 21:52), Steven Rostedt wrote:
> On Wed, 24 Jan 2018 11:11:33 +0900
> Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:
> 
> > Please take a look.
> 
> Was there something specific to look at?

Not really. Just my previous email, basically.
You said "I have to look at the latest code." so I replied.

Well, if the proposed direction does make sense then I'll send
out a patch.


> I'm doing a hundred different things at once, and my memory cache...

Meltdown vulnerable? Suddenly it all makes sense - you talk too fast
because of speculative execution... ;)

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
