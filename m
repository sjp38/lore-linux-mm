Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B22176B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:41:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q15so9883314pff.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:41:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s16-v6si836403plp.487.2018.04.16.11.41.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 11:41:21 -0700 (PDT)
Date: Mon, 16 Apr 2018 14:41:17 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416144117.5757ee70@gandalf.local.home>
In-Reply-To: <CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
References: <20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416122019.1c175925@gandalf.local.home>
	<20180416162757.GB2341@sasha-vm>
	<20180416163952.GA8740@amd>
	<20180416164310.GF2341@sasha-vm>
	<20180416125307.0c4f6f28@gandalf.local.home>
	<20180416170936.GI2341@sasha-vm>
	<20180416133321.40a166a4@gandalf.local.home>
	<20180416174236.GL2341@sasha-vm>
	<20180416142653.0f017647@gandalf.local.home>
	<CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 11:30:06 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Apr 16, 2018 at 11:26 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > The problem is that it only fixed a critical bug, but didn't go far
> > enough to keep the bug fix from breaking API.  
> 
> An API breakage that gets noticed *is* a crtitical bug.

I totally agree with you. You misunderstood what I wrote.

I said there were two bugs here. The first bug was a possible accessing
bad memory bug. That needed to be fixed. The problem was by fixing
that, it broke API. But that's because the original code was broken
where it relied on broken code to get right. I never said the second
bug fix should not have been backported. I even said that the first bug
"didn't go far enough".

I hope the answer was not to revert the bug and put back the possible
bad memory access in to keep API. But it was to backport the second bug
fix that still has the first fix, but fixes the API breakage.

Yes, an API breakage is something I would label as critical to be
backported.

-- Steve
