Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E32836B0009
	for <linux-mm@kvack.org>; Thu,  3 May 2018 09:06:56 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id z6-v6so12008750pgu.20
        for <linux-mm@kvack.org>; Thu, 03 May 2018 06:06:56 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0120.outbound.protection.outlook.com. [104.47.32.120])
        by mx.google.com with ESMTPS id f4-v6si13292791plf.543.2018.05.03.06.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 May 2018 06:06:55 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Thu, 3 May 2018 13:06:50 +0000
Message-ID: <20180503130646.GG18390@sasha-vm>
References: <20180416155031.GX2341@sasha-vm> <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm> <20180416170501.GB11034@amd>
 <20180416171607.GJ2341@sasha-vm>
 <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
 <20180416203629.GO2341@sasha-vm>
 <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
 <20180416211845.GP2341@sasha-vm> <20180503094724.GD32180@amd>
In-Reply-To: <20180503094724.GD32180@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C5B5F51B140A0B4B9977D968BE5B2B27@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Jiri Kosina <jikos@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Thu, May 03, 2018 at 11:47:24AM +0200, Pavel Machek wrote:
>On Mon 2018-04-16 21:18:47, Sasha Levin wrote:
>> On Mon, Apr 16, 2018 at 10:43:28PM +0200, Jiri Kosina wrote:
>> >On Mon, 16 Apr 2018, Sasha Levin wrote:
>> >
>> >> So I think that Linus's claim that users come first applies here as
>> >> well. If there's a user that cares about a particular feature being
>> >> broken, then we go ahead and fix his bug rather then ignoring him.
>> >
>> >So one extreme is fixing -stable *iff* users actually do report an issu=
e.
>> >
>> >The other extreme is backporting everything that potentially looks like=
 a
>> >potential fix of "something" (according to some arbitrary metric),
>> >pro-actively.
>> >
>> >The former voilates the "users first" rule, the latter has a very, very
>> >high risk of regressions.
>> >
>> >So this whole debate is about finding a compromise.
>> >
>> >My gut feeling always was that the statement in
>> >
>> >	Documentation/process/stable-kernel-rules.rst
>> >
>> >is very reasonable, but making the process way more "aggresive" when
>> >backporting patches is breaking much of its original spirit for me.
>>
>> I agree that as an enterprise distro taking everything from -stable
>> isn't the best idea. Ideally you'd want to be close to the first
>
>Original purpose of -stable was "to be common base of enterprise
>distros" and our documentation still says it is.

I guess that the world changes?

At this point calling enterprise distros a niche wouldn't be too far
from the truth. Furthermore, some enterprise distros (as stated
earlier in this thread) don't even follow -stable anymore and cherry
pick their own commits.

So no, the main driving force behind -stable is not traditional
enterprise distributions.

>> I think that we can agree that it's impossible to expect every single
>> Linux user to go on LKML and complain about a bug he encountered, so the
>> rule quickly becomes "It must fix a real bug that can bother
>> people".
>
>I think you are playing dangerous word games.
>
>> My "aggressiveness" comes from the whole "bother" part: it doesn't have
>> to be critical, it doesn't have to cause data corruption, it doesn't
>> have to be a security issue. It's enough that the bug actually affects a
>> user in a way he didn't expect it to (if a user doesn't have
>> expectations, it would fall under the "This could be a problem..."
>> exception.
>
>And it seems documentation says you should be less aggressive and
>world tells you they expect to be less aggressive. So maybe that's
>what you should do?

Who is this "world" you're referring to?=
