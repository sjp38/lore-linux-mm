Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB2596B026E
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:14:19 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m3so14383710ioe.17
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:14:19 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0127.outbound.protection.outlook.com. [104.47.38.127])
        by mx.google.com with ESMTPS id q1-v6si5838495itc.46.2018.04.16.09.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 09:14:18 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 16:14:15 +0000
Message-ID: <20180416161412.GZ2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
In-Reply-To: <20180416160608.GA7071@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <484B7B48C36AD843B28BB9CEC90806E6@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 06:06:08PM +0200, Pavel Machek wrote:
>On Mon 2018-04-16 15:50:34, Sasha Levin wrote:
>> On Mon, Apr 16, 2018 at 05:30:31PM +0200, Pavel Machek wrote:
>> >On Mon 2018-04-16 08:18:09, Linus Torvalds wrote:
>> >> On Mon, Apr 16, 2018 at 6:30 AM, Steven Rostedt <rostedt@goodmis.org>=
 wrote:
>> >> >
>> >> > I wonder if the "AUTOSEL" patches should at least have an "ack-by" =
from
>> >> > someone before they are pulled in. Otherwise there may be some subt=
le
>> >> > issues that can find their way into stable releases.
>> >>
>> >> I don't know about anybody else, but I  get so many of the patch-bot
>> >> patches for stable etc that I will *not* reply to normal cases. Only
>> >> if there's some issue with a patch will I reply.
>> >>
>> >> I probably do get more than most, but still - requiring active
>> >> participation for the steady flow of normal stable patches is almost
>> >> pointless.
>> >>
>> >> Just look at the subject line of this thread. The numbers are so big
>> >> that you almost need exponential notation for them.
>> >
>> >Question is if we need that many stable patches? Autosel seems to be
>> >picking up race conditions in LED state and W+X page fixes... I'd
>> >really like to see less stable patches.
>>
>> Why? Given that the kernel keeps seeing more and more lines of code in
>> each new release, tools around the kernel keep evolving (new fuzzers,
>> testing suites, etc), and code gets more eyes, this guarantees that
>> you'll see more and more stable patches for each release as well.
>>
>> Is there a reason not to take LED fixes if they fix a bug and don't
>> cause a regression? Sure, we can draw some arbitrary line, maybe
>> designate some subsystems that are more "important" than others, but
>> what's the point?
>
>There's a tradeoff.
>
>You want to fix serious bugs in stable, and you really don't want
>regressions in stable. And ... stable not having 1000s of patches
>would be nice, too.

I don't think we should use a number cap here, but rather look at the
regression rate: how many patches broke something?

Since the rate we're seeing now with AUTOSEL is similar to what we were
seeing before AUTOSEL, what's the problem it's causing?

>That means you want to ignore not-so-serious bugs, because benefit of
>fixing them is lower than risk of the regressions. I believe bugs that
>do not bother anyone should _not_ be fixed in stable.
>
>That was case of the LED patch. Yes, the commit fixed bug, but it
>introduced regressions that were fixed by subsequent patches.

How do you know if a bug bothers someone?

If a user is annoyed by a LED issue, is he expected to triage the bug,
report it on LKML and patiently wait for the appropriate patch to be
backported?=
