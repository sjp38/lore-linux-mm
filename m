Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 323D06B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:52:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m3so14751421ioe.17
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:52:50 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d1sor5070865ioj.263.2018.04.16.11.52.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 11:52:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416144117.5757ee70@gandalf.local.home>
References: <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm> <20180416163952.GA8740@amd>
 <20180416164310.GF2341@sasha-vm> <20180416125307.0c4f6f28@gandalf.local.home>
 <20180416170936.GI2341@sasha-vm> <20180416133321.40a166a4@gandalf.local.home>
 <20180416174236.GL2341@sasha-vm> <20180416142653.0f017647@gandalf.local.home>
 <CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com> <20180416144117.5757ee70@gandalf.local.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Apr 2018 11:52:48 -0700
Message-ID: <CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, Apr 16, 2018 at 11:41 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
>I never said the second
> bug fix should not have been backported. I even said that the first bug
> "didn't go far enough".

You're still not getting it.

The "didn't go far enough" means that the bug fix is *BUGGY*. It needs
to be reverted.

> I hope the answer was not to revert the bug and put back the possible
> bad memory access in to keep API.

But that very must *IS* the answer. If there isn't a fix for the ABI
breakage, then the first bugfix needs to be reverted.

Really. There is no such thing as "but the fix was more important than
the bug it introduced".

This is why we started with the whole "actively revert things that
introduce regressions". Because people always kept claiming that "but
but I fixed a worse bug, and it's better to fix the worse bug even if
it then introduces another problem, because the other problem is
lesser".

NO.

We're better off making *no* progress, than making "unsteady progress".

Really. Seriously.

If you cannot fix a bug without introducing another one, don't do it.
Don't do kernel development.

The whole mentality you show is NOT ACCEPTABLE.

So the *only* answer is: "fix the bug _and_ keep the API".  There is
no other choice.

The whole "I fixed one problem but introduced another" is not how we
work. You should damn well know that. There are no excuses.

And yes, sometimes that means jumping through hoops. But that's what
it takes to keep users happy.

                 Linus
