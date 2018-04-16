Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4F0A6B026A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:02:07 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id a62-v6so9585850itd.6
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:02:07 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0106.outbound.protection.outlook.com. [104.47.38.106])
        by mx.google.com with ESMTPS id 137-v6si5656854ite.16.2018.04.16.09.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 09:02:06 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 16:02:03 +0000
Message-ID: <20180416160200.GY2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home>
In-Reply-To: <20180416113629.2474ae74@gandalf.local.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C48F265BB7B6F44681ADEEE91A5DE688@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon, Apr 16, 2018 at 11:36:29AM -0400, Steven Rostedt wrote:
>On Mon, 16 Apr 2018 08:18:09 -0700
>Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
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
>>
>
>I'm worried about just backporting patches that nobody actually looked
>at. Is someone going through and vetting that these should definitely
>be added to stable. I would like to have some trusted human (doesn't
>even need to be the author or maintainer of the patch) to look at all
>the patches before they are applied.

I do go through every single commit sent this way and review it.
Sometimes things slip by, but it's not a fully automatic process.

Let's look at this patch as a concrete example: the only reason,
according to the stable rules, that it shouldn't go in -stable is that
it's longer than 100 lines.

Otherwise, it fixes a bug, it doesn't introduce any new features, it's
upstream, and so on. It had some fixes that went upstream as well?
Great, let's grab those as well.

>I would say anything more than a trivial patch would require author or
>sub maintainer ack. Look at this patch, I don't think it should go to
>stable, even though it does fix issues. But the fix is for systems
>already having issues, and this keeps printk from making things worse.
>The fix has side effects that other commits have addressed, and if this
>patch gets backported, those other ones must too.

Sure, let's get those patches in as well.

One of the things Greg is pushing strongly for is "bug compatibility":
we want the kernel to behave the same way between mainline and stable.
If the code is broken, it should be broken in the same way.

If anything, after this discussion I'd recommend that we take this patch
and it's follow-up fixes...

>Maybe I was too strong by saying all patches should be acked, but
>anything more than buffer overflows and off by one errors probably
>require a bit more vetting by a human than to just pull in all patches
>that a bot flags to be backported.

If anyone wants to give me a hand with going through these I'd be more
than happy to. I know that Ben Hutchings is looking at the ones that
land in 4.4 carefully. It's always good to have more than 1 set of eyes!=
