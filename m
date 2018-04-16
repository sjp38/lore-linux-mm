Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 997606B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:55:48 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id p18so15205733ioe.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:55:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t7-v6sor4572566itf.49.2018.04.16.12.55.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 12:55:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416153816.292a5b5c@gandalf.local.home>
References: <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm> <20180416163952.GA8740@amd>
 <20180416164310.GF2341@sasha-vm> <20180416125307.0c4f6f28@gandalf.local.home>
 <20180416170936.GI2341@sasha-vm> <20180416133321.40a166a4@gandalf.local.home>
 <20180416174236.GL2341@sasha-vm> <20180416142653.0f017647@gandalf.local.home>
 <CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
 <20180416144117.5757ee70@gandalf.local.home> <CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
 <20180416152429.529e3cba@gandalf.local.home> <CA+55aFwjSRZDT1f99QdY-Q5R4W_asb_1mZgM69YOqRR9-efmwA@mail.gmail.com>
 <20180416153816.292a5b5c@gandalf.local.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Apr 2018 12:55:46 -0700
Message-ID: <CA+55aFwXRjgfLfAWSaLBdajjzh4gt8-5M2N-bmjKt8nrJT+vWQ@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, Apr 16, 2018 at 12:38 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> But I don't see in the git history that this was ever reverted. My reply
> saying that "I hope it wasn't reverted", was a response for it being
> reverted in stable, not mainline.

See my other email.

If your'e stable maintainer, and you get a report of a commit that
causes problems, your first reaction probably really should just be
"revert it".

You can always re-apply it later, but a patch that causes problems is
absolutely very much suspect, and automatically should make any stable
maintainer go "that needs much more analysis".

Sure, hopefully automation finds the fix too (ie commit 21b81716c6bf
"ipr: Fix regression when loading firmware") in mainline.

It did have the proper "fixes" tag, so it should hopefully have been
easy to find by the automation that stable people use.

But at the same time, I still  maintain that "just revert it" is
rather likely the right solution for stable. If it had a bug once,
maybe it shouldn't have been applied in the first place.

The author can then get notified by the other stable automation, and
at that point argue for "yeah, it was buggy, but together with this
other fix it's really important".

But even when that is the case, I really don't see that the author
should complain about it being reverted. Because it's *such* a
no-brainer in stable.

               Linus
