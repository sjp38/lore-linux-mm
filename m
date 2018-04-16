Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A037D6B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:30:08 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id z70so11022711iof.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:30:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v66-v6sor3424586itb.51.2018.04.16.11.30.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 11:30:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416142653.0f017647@gandalf.local.home>
References: <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm> <20180416163952.GA8740@amd>
 <20180416164310.GF2341@sasha-vm> <20180416125307.0c4f6f28@gandalf.local.home>
 <20180416170936.GI2341@sasha-vm> <20180416133321.40a166a4@gandalf.local.home>
 <20180416174236.GL2341@sasha-vm> <20180416142653.0f017647@gandalf.local.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Apr 2018 11:30:06 -0700
Message-ID: <CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, Apr 16, 2018 at 11:26 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> The problem is that it only fixed a critical bug, but didn't go far
> enough to keep the bug fix from breaking API.

An API breakage that gets noticed *is* a crtitical bug.

You can't call something else critical and then say "but it broken API".

Seriously. Why do I even have to mention this?

If you break user workflows, NOTHING ELSE MATTERS.

Even security is secondary to "people don't use the end result,
because it doesn't work for them any more".

Really.

Stop with this idiotic "only API". Breaking user space is just about
the only thing that really matters. The rest is "small matter of
implementation".

              Linus
