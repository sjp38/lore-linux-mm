Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E37F6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:02:39 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 35-v6so6720355pla.18
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:02:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x7si5321690pgb.300.2018.04.16.13.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 13:02:36 -0700 (PDT)
Date: Mon, 16 Apr 2018 16:02:32 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416160232.2b807ff1@gandalf.local.home>
In-Reply-To: <CA+55aFwXRjgfLfAWSaLBdajjzh4gt8-5M2N-bmjKt8nrJT+vWQ@mail.gmail.com>
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
	<20180416153816.292a5b5c@gandalf.local.home>
	<CA+55aFwXRjgfLfAWSaLBdajjzh4gt8-5M2N-bmjKt8nrJT+vWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 12:55:46 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Apr 16, 2018 at 12:38 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > But I don't see in the git history that this was ever reverted. My reply
> > saying that "I hope it wasn't reverted", was a response for it being
> > reverted in stable, not mainline.  
> 
> See my other email.

Already replied.

> 
> If your'e stable maintainer, and you get a report of a commit that
> causes problems, your first reaction probably really should just be
> "revert it".
> 
> You can always re-apply it later, but a patch that causes problems is
> absolutely very much suspect, and automatically should make any stable
> maintainer go "that needs much more analysis".
> 
> Sure, hopefully automation finds the fix too (ie commit 21b81716c6bf
> "ipr: Fix regression when loading firmware") in mainline.
> 
> It did have the proper "fixes" tag, so it should hopefully have been
> easy to find by the automation that stable people use.
> 
> But at the same time, I still  maintain that "just revert it" is
> rather likely the right solution for stable. If it had a bug once,
> maybe it shouldn't have been applied in the first place.
> 
> The author can then get notified by the other stable automation, and
> at that point argue for "yeah, it was buggy, but together with this
> other fix it's really important".
> 
> But even when that is the case, I really don't see that the author
> should complain about it being reverted. Because it's *such* a
> no-brainer in stable.

But this is going way off topic to what we were discussing. The
discussion is about what gets backported. Is automating the process
going to make stable better? Or is it likely to add more regressions.

Sasha's response has been that his automated process has the same rate
of regressions as what gets tagged by authors. My argument is that
perhaps authors should tag less to stable.

-- Steve
