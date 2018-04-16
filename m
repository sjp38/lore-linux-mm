Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 455C96B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:44:28 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d9-v6so1725687plj.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:44:28 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v127si8781169pgv.27.2018.04.16.10.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 10:44:27 -0700 (PDT)
Date: Mon, 16 Apr 2018 13:44:23 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416134423.2b60ff13@gandalf.local.home>
In-Reply-To: <20180416171607.GJ2341@sasha-vm>
References: <20180409001936.162706-15-alexander.levin@microsoft.com>
	<20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
	<20180415144248.GP2341@sasha-vm>
	<20180416093058.6edca0bb@gandalf.local.home>
	<CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
	<20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416161412.GZ2341@sasha-vm>
	<20180416170501.GB11034@amd>
	<20180416171607.GJ2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, 16 Apr 2018 17:16:10 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

 
> So if a user is operating a nuclear power plant, and has 2 leds: green
> one that says "All OK!" and a red one saying "NUCLEAR MELTDOWN!", and
> once in a blue moon a race condition is causing the red one to go on and
> cause panic in the little province he lives in, we should tell that user
> to fuck off?
> 
> LEDs may not be critical for you, but they can be critical for someone
> else. Think of all the different users we have and the wildly different
> ways they use the kernel.

We can point them to the fix and have them backport it. Or they should
ask their distribution to backport it.

Hopefully they tested the kernel they are using for something like
that, and only want critical fixes. What happens if they take the next
stable assuming that it has critical fixes only, and this fix causes a
regression that creates the "ALL OK!" when it wasn't.

Basically, I rather have stable be more bug compatible with the version
it is based on with only critical fixes (things that will cause an
oops) than to try to be bug compatible with mainline, as then we get
into a state where things are a frankenstein of the stable base version
and mainline. I could say, "Yeah this feature works better on this
4.x version of the kernel" and not worry about "4.x.y" versions having
it better.

-- Steve
