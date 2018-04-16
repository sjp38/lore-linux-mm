Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0906B000A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:39:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q15so9639320pff.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:39:09 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0094.outbound.protection.outlook.com. [104.47.36.94])
        by mx.google.com with ESMTPS id y4si10817962pfd.59.2018.04.16.08.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 08:39:08 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 15:39:04 +0000
Message-ID: <20180416153902.GW2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
In-Reply-To: <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6232387AC99B4C40BAA80F3AC774256D@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon, Apr 16, 2018 at 08:18:09AM -0700, Linus Torvalds wrote:
>On Mon, Apr 16, 2018 at 6:30 AM, Steven Rostedt <rostedt@goodmis.org> wrot=
e:
>>
>> I wonder if the "AUTOSEL" patches should at least have an "ack-by" from
>> someone before they are pulled in. Otherwise there may be some subtle
>> issues that can find their way into stable releases.
>
>I don't know about anybody else, but I  get so many of the patch-bot
>patches for stable etc that I will *not* reply to normal cases. Only
>if there's some issue with a patch will I reply.
>
>I probably do get more than most, but still - requiring active
>participation for the steady flow of normal stable patches is almost
>pointless.
>
>Just look at the subject line of this thread. The numbers are so big
>that you almost need exponential notation for them.
>
>           Linus

I would be more than happy to make this an opt-in process on my end, but
given the responses I've been seeing from folks so far I doubt it'll
work for many people. Humans don't scale :)

There are a few statistics that suggest that the current workflow is
"good enough":

	1. The rejection rate (commits fixed or reverted) for
	AUTOSEL commits is similar (actually smaller) than commits
	tagged for -stable.

	2. Human response rate on review requests is higher than the
	rate Greg is getting with his review mails. This is somewhat
	expected, but it shows that people do what Linus does and reply
	just when they see something wrong.

I also think that using mailing lists for these is bringing up the
limitations of mailing lists. It's hard to go through the amount of
patches AUTOSEL is generating this way, but right now we don't have a
better alternative.=
