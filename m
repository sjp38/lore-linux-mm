Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6E656B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:38:21 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 91-v6so10848961plf.6
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:38:21 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v31-v6si12808037plg.157.2018.04.16.12.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 12:38:21 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:38:16 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416153816.292a5b5c@gandalf.local.home>
In-Reply-To: <CA+55aFwjSRZDT1f99QdY-Q5R4W_asb_1mZgM69YOqRR9-efmwA@mail.gmail.com>
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
	<20180416144117.5757ee70@gandalf.local.home>
	<CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
	<20180416152429.529e3cba@gandalf.local.home>
	<CA+55aFwjSRZDT1f99QdY-Q5R4W_asb_1mZgM69YOqRR9-efmwA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 12:28:21 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Apr 16, 2018 at 12:24 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > Right, but the fix to the API was also trivial. I don't understand why
> > you are arguing with me. I agree with you. I'm talking about this
> > specific instance. Where a bug was fixed, and the API breakage was
> > another fix that needed to be backported.  
> 
> Fair enough. Were you there when the report of breakage came in?

No I wasn't.

> 
> Because *my* argument is that reverting something that causes problems
> is simply *never* the wrong answer.
> 
> If you know of the fix, fine. But clearly people DID NOT KNOW. So
> reverting was the right choice.

But I don't see in the git history that this was ever reverted. My reply
saying that "I hope it wasn't reverted", was a response for it being
reverted in stable, not mainline.  Considering that the original bug
would allow userspace to write zeros anywhere in memory, I would have
definitely worked on finding why the API breakage happened and fixing
it properly before putting such a large hole back into the kernel.

I'm assuming that may have been what happened because the commit was
never reverted in your tree, and if I was responsible for that code, I
would be up all night looking for an API fix to make sure the original
fix isn't reverted.

-- Steve
