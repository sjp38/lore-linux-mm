Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 708846B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 04:22:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a6so4776367pfn.3
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 01:22:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a59-v6si14279474pla.497.2018.04.09.01.22.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 01:22:49 -0700 (PDT)
Date: Mon, 9 Apr 2018 10:22:46 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409001936.162706-15-alexander.levin@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon 2018-04-09 00:19:53, Sasha Levin wrote:
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

Same here. I do not thing that this is a material for stable backport.
More details can be found in my reply to the patch for 4.15, see
https://lkml.kernel.org/r/20180409081535.dq7p5bfnpvd3xk3t@pathway.suse.cz

Best Regards,
Petr

PS: I wonder how much time you give people to react before releasing
this. The number of autosel mails is increasing and I am involved
only in very small amount of them. I wonder if some other people
gets overwhelmed by this.
