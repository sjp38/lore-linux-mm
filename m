Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 081BA6B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:18:08 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o8so13680638wra.12
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:18:07 -0700 (PDT)
Received: from twin.jikos.cz (twin.jikos.cz. [91.219.245.39])
        by mx.google.com with ESMTPS id m7si5678379wmb.115.2018.04.16.13.18.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 13:18:06 -0700 (PDT)
Date: Mon, 16 Apr 2018 22:17:17 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
In-Reply-To: <20180416171607.GJ2341@sasha-vm>
Message-ID: <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
References: <20180409001936.162706-15-alexander.levin@microsoft.com> <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz> <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home> <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm> <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm> <20180416170501.GB11034@amd> <20180416171607.GJ2341@sasha-vm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, 16 Apr 2018, Sasha Levin wrote:

> So if a user is operating a nuclear power plant, and has 2 leds: green 
> one that says "All OK!" and a red one saying "NUCLEAR MELTDOWN!", and 
> once in a blue moon a race condition is causing the red one to go on and 
> cause panic in the little province he lives in, we should tell that user 
> to fuck off?
> 
> LEDs may not be critical for you, but they can be critical for someone
> else. Think of all the different users we have and the wildly different
> ways they use the kernel.

I am pretty sure that for almost every fix there is a person on a planet 
that'd rate it "critical". We can't really use this as an argument for 
inclusion of code into -stable, as that'd mean that -stable and Linus' 
tree would have to be basically the same.

-- 
Jiri Kosina
SUSE Labs
