Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F35736B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:18:11 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id y131-v6so9463406itc.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:18:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m21-v6sor4221999iti.79.2018.04.16.08.18.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 08:18:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416093058.6edca0bb@gandalf.local.home>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com> <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Apr 2018 08:18:09 -0700
Message-ID: <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon, Apr 16, 2018 at 6:30 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> I wonder if the "AUTOSEL" patches should at least have an "ack-by" from
> someone before they are pulled in. Otherwise there may be some subtle
> issues that can find their way into stable releases.

I don't know about anybody else, but I  get so many of the patch-bot
patches for stable etc that I will *not* reply to normal cases. Only
if there's some issue with a patch will I reply.

I probably do get more than most, but still - requiring active
participation for the steady flow of normal stable patches is almost
pointless.

Just look at the subject line of this thread. The numbers are so big
that you almost need exponential notation for them.

           Linus
