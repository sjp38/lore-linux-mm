Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 37F7A6B026F
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:20:24 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q6so2929328pgv.12
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:20:24 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w15-v6si4961973plq.183.2018.04.16.09.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:20:22 -0700 (PDT)
Date: Mon, 16 Apr 2018 12:20:19 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416122019.1c175925@gandalf.local.home>
In-Reply-To: <20180416160608.GA7071@amd>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
	<20180409001936.162706-15-alexander.levin@microsoft.com>
	<20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
	<20180415144248.GP2341@sasha-vm>
	<20180416093058.6edca0bb@gandalf.local.home>
	<CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
	<20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, 16 Apr 2018 18:06:08 +0200
Pavel Machek <pavel@ucw.cz> wrote:

> That means you want to ignore not-so-serious bugs, because benefit of
> fixing them is lower than risk of the regressions. I believe bugs that
> do not bother anyone should _not_ be fixed in stable.
> 
> That was case of the LED patch. Yes, the commit fixed bug, but it
> introduced regressions that were fixed by subsequent patches.

I agree. I would disagree that the patch this thread is on should go to
stable. What's the point of stable if it introduces regressions by
backporting bug fixes for non major bugs.

Every fix I make I consider labeling it for stable. The ones I don't, I
feel the bug fix is not worth the risk of added regressions.

I worry that people will get lazy and stop marking commits for stable
(or even thinking about it) because they know that there's a bot that
will pull it for them. That thought crossed my mind. Why do I want to
label anything stable if a bot will probably catch it. Then I could
just wait till the bot posts it before I even think about stable.

-- Steve
