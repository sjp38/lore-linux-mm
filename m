Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4479E6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:31:04 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d9-v6so1388636plj.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 06:31:04 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y9si9666201pgr.180.2018.04.16.06.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 06:31:02 -0700 (PDT)
Date: Mon, 16 Apr 2018 09:30:58 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416093058.6edca0bb@gandalf.local.home>
In-Reply-To: <20180415144248.GP2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
	<20180409001936.162706-15-alexander.levin@microsoft.com>
	<20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
	<20180415144248.GP2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Sun, 15 Apr 2018 14:42:51 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

> On Mon, Apr 09, 2018 at 10:22:46AM +0200, Petr Mladek wrote:
> >PS: I wonder how much time you give people to react before releasing
> >this. The number of autosel mails is increasing and I am involved
> >only in very small amount of them. I wonder if some other people
> >gets overwhelmed by this.  
> 
> My review cycle gives at least a week, and there's usually another week
> until Greg releases them.
> 
> I know it's a lot of mails, but in reality it's a lot of commits that
> should go in -stable.
> 
> Would a different format for review would make it easier?

I wonder if the "AUTOSEL" patches should at least have an "ack-by" from
someone before they are pulled in. Otherwise there may be some subtle
issues that can find their way into stable releases.

-- Steve
