Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D54AE6B0266
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:50:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q6so2909451pgv.12
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:50:39 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0129.outbound.protection.outlook.com. [104.47.32.129])
        by mx.google.com with ESMTPS id t20si11260551pfk.228.2018.04.16.08.50.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 08:50:38 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 15:50:34 +0000
Message-ID: <20180416155031.GX2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
In-Reply-To: <20180416153031.GA5039@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F0FE53AA5F1E3943A62B6A5ED90CC075@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 05:30:31PM +0200, Pavel Machek wrote:
>On Mon 2018-04-16 08:18:09, Linus Torvalds wrote:
>> On Mon, Apr 16, 2018 at 6:30 AM, Steven Rostedt <rostedt@goodmis.org> wr=
ote:
>> >
>> > I wonder if the "AUTOSEL" patches should at least have an "ack-by" fro=
m
>> > someone before they are pulled in. Otherwise there may be some subtle
>> > issues that can find their way into stable releases.
>>
>> I don't know about anybody else, but I  get so many of the patch-bot
>> patches for stable etc that I will *not* reply to normal cases. Only
>> if there's some issue with a patch will I reply.
>>
>> I probably do get more than most, but still - requiring active
>> participation for the steady flow of normal stable patches is almost
>> pointless.
>>
>> Just look at the subject line of this thread. The numbers are so big
>> that you almost need exponential notation for them.
>
>Question is if we need that many stable patches? Autosel seems to be
>picking up race conditions in LED state and W+X page fixes... I'd
>really like to see less stable patches.

Why? Given that the kernel keeps seeing more and more lines of code in
each new release, tools around the kernel keep evolving (new fuzzers,
testing suites, etc), and code gets more eyes, this guarantees that
you'll see more and more stable patches for each release as well.

Is there a reason not to take LED fixes if they fix a bug and don't
cause a regression? Sure, we can draw some arbitrary line, maybe
designate some subsystems that are more "important" than others, but
what's the point?=
