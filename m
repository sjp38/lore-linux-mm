Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 362136B0023
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:28:10 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t5so7242457ioc.1
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:28:10 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0109.outbound.protection.outlook.com. [104.47.38.109])
        by mx.google.com with ESMTPS id f204-v6si5839732itc.76.2018.04.16.09.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 09:28:09 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 16:28:00 +0000
Message-ID: <20180416162757.GB2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home>
In-Reply-To: <20180416122019.1c175925@gandalf.local.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <32A693D44F62364C9CE7D7F0F3157A72@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 12:20:19PM -0400, Steven Rostedt wrote:
>On Mon, 16 Apr 2018 18:06:08 +0200
>Pavel Machek <pavel@ucw.cz> wrote:
>
>> That means you want to ignore not-so-serious bugs, because benefit of
>> fixing them is lower than risk of the regressions. I believe bugs that
>> do not bother anyone should _not_ be fixed in stable.
>>
>> That was case of the LED patch. Yes, the commit fixed bug, but it
>> introduced regressions that were fixed by subsequent patches.
>
>I agree. I would disagree that the patch this thread is on should go to
>stable. What's the point of stable if it introduces regressions by
>backporting bug fixes for non major bugs.

One such reason is that users will then hit the regression when they
upgrade to the next -stable version anyways.

>Every fix I make I consider labeling it for stable. The ones I don't, I
>feel the bug fix is not worth the risk of added regressions.
>
>I worry that people will get lazy and stop marking commits for stable
>(or even thinking about it) because they know that there's a bot that
>will pull it for them. That thought crossed my mind. Why do I want to
>label anything stable if a bot will probably catch it. Then I could
>just wait till the bot posts it before I even think about stable.

People are already "lazy". You are actually an exception for marking your
commits.

Yes, folks will chime in with "sure, I mark my patches too!", but if you
look at the entire committer pool in the kernel you'll see that most
don't bother with this to begin with.=
