Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE3416B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:58:08 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w5-v6so1041502plz.17
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:58:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e6si11082982pfg.305.2018.04.16.12.58.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 12:58:07 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:58:03 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416155803.00aaa5d7@gandalf.local.home>
In-Reply-To: <CA+55aFxVg4FOhvxcrqi7Fs8ohsgSh8DURu3ESbovc_sBxxxpiQ@mail.gmail.com>
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
	<CA+55aFxVg4FOhvxcrqi7Fs8ohsgSh8DURu3ESbovc_sBxxxpiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 12:31:09 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> But the -stable tree?
> 
> Seriously, what do you expect them to do if they get a report that a
> commit they added to the stable tree regresses?
> 
> "Revert first, ask questions later" is definitely a very sane model there.

The topic of our discussion is on what to backport, and how likely is
it to cause regressions. I'm arguing that the bar for backporting
should be raised, and that only "critical" fixes should be backported.
Sasha pointed this bug fix as an example, and asked me if I would
backport it under my conditions. I said yes. He then said "it was
reverted", pointing me to the commit that fixed it. That confused
me. When I looked further, I noticed that it wasn't reverted, and since
he pointed me to the API fix, I said "I hope it wasn't reverted"
meaning I hope they backported the obvious API fix and didn't just
revert the original fix.

-- Steve
