Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCE0F6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:33:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b18so2978249pgv.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:33:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s14si4464224pgf.688.2018.04.16.10.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 10:33:25 -0700 (PDT)
Date: Mon, 16 Apr 2018 13:33:21 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416133321.40a166a4@gandalf.local.home>
In-Reply-To: <20180416170936.GI2341@sasha-vm>
References: <20180416093058.6edca0bb@gandalf.local.home>
	<CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
	<20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416122019.1c175925@gandalf.local.home>
	<20180416162757.GB2341@sasha-vm>
	<20180416163952.GA8740@amd>
	<20180416164310.GF2341@sasha-vm>
	<20180416125307.0c4f6f28@gandalf.local.home>
	<20180416170936.GI2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 17:09:38 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

> Let's play a "be the -stable maintainer" game. Would you take any
> of the following commits?
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit?id=fc90441e728aa461a8ed1cfede08b0b9efef43fb

No, not automatically, or without someone from KVM letting me know what
side-effects that may have. Not stopping on a breakpoint is not that
critical, it may be a bit annoying. I would ask the KVM maintainers if
they feel it's critical enough for backporting, but without hearing
from them, I would leave it be.

> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit?id=a918d2bcea6aab6e671bfb0901cbecc3cf68fca1

Sure. Even if it has a subtle regression, that's a critical bug being
fixed.

> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit?id=b1999fa6e8145305a6c8bda30ea20783717708e6

I would consider unlocking a mutex that one didn't lock a critical bug,
so yes.

Again, things that deal with locking or buffer overflows, I would take
the fix, as those are critical. But other behavior issues where it's
not critical, I would leave be unless told further by someone else.

-- Steve
