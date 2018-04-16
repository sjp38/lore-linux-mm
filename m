Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 754A56B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:35:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 127so803410pge.10
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:35:15 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k2-v6si12574906plt.406.2018.04.16.11.35.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 11:35:14 -0700 (PDT)
Date: Mon, 16 Apr 2018 14:35:10 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416143510.79ba5c63@gandalf.local.home>
In-Reply-To: <20180416181715.GM2341@sasha-vm>
References: <20180415144248.GP2341@sasha-vm>
	<20180416093058.6edca0bb@gandalf.local.home>
	<CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
	<20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416161412.GZ2341@sasha-vm>
	<20180416170501.GB11034@amd>
	<20180416171607.GJ2341@sasha-vm>
	<20180416134423.2b60ff13@gandalf.local.home>
	<20180416181715.GM2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, 16 Apr 2018 18:17:17 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

> I thought we agreed that this is bad? We wanted users to be closer to
> mainline, and we can't do it without bringing -stable closer to mainline
> as well.

I guess the question comes down to, what do the users of stable kernels
want? For my machines, I always stay one or two releases behind
mainline. Right now my kernels are on 4.15.x, and will probably jump to
4.16.x the next time I upgrade my machines. I'm fine with something
breaking every so often as long as it's not data corruption (although I
have lots of backups of my systems in case that happens, just a PITA to
fix it). I only hit bugs on these boxes probably once a year at most in
doing so. But I mostly do what other kernel developers do and that
means the bugs I would mostly hit, other developers hit before their
code is released.

Thus, if stable users are fine with being regression compatible with
mainline, then I'm fine with it too.

-- Steve
