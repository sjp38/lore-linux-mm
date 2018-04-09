Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CACB36B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 04:15:42 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id u11-v6so4693657pls.22
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 01:15:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si8347434pfh.196.2018.04.09.01.15.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 01:15:41 -0700 (PDT)
Date: Mon, 9 Apr 2018 10:15:35 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH AUTOSEL for 4.15 019/189] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180409081535.dq7p5bfnpvd3xk3t@pathway.suse.cz>
References: <20180409001637.162453-1-alexander.levin@microsoft.com>
 <20180409001637.162453-19-alexander.levin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409001637.162453-19-alexander.levin@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon 2018-04-09 00:16:59, Sasha Levin wrote:
> From: "Steven Rostedt (VMware)" <rostedt@goodmis.org>
> 
> [ Upstream commit dbdda842fe96f8932bae554f0adf463c27c42bc7 ]
> 
> This patch implements what I discussed in Kernel Summit. I added
> lockdep annotation (hopefully correctly), and it hasn't had any splats
> (since I fixed some bugs in the first iterations). It did catch
> problems when I had the owner covering too much. But now that the owner
> is only set when actively calling the consoles, lockdep has stayed
> quiet.

I do not think that this is a material for stable backports. Yes, it
is a fix but it is not trivial. There are already 3 follow up commits:

c162d5b4338d72deed6 ("printk: Hide console waiter logic into helpers")
fd5f7cde1b85d4c8e09 ("printk: Never set console_may_schedule in
		console_trylock()")
c14376de3a1befa70d9 ("printk: Wake klogd when passing console_lock owner")

One is just a code clean up but the other two are changes/fixes that
should go together with Steven's patch.

These changes tries to prevent softlockups. It is a problem that is
being discussed for years. We are still waiting for feedback to see if
more changes will be necessary. IMHO, there is no reason to hurry and
backport it everywhere.

Best Regards,
Petr
