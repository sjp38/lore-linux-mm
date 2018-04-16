Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18E6F6B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:36:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k3so8126403pff.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:36:37 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0104.outbound.protection.outlook.com. [104.47.32.104])
        by mx.google.com with ESMTPS id p5si9797953pgu.158.2018.04.16.13.36.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 13:36:35 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 20:36:32 +0000
Message-ID: <20180416203629.GO2341@sasha-vm>
References: <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm>
 <20180416170501.GB11034@amd> <20180416171607.GJ2341@sasha-vm>
 <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
In-Reply-To: <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <DD73776144F18247B8761508E6580A5C@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 10:17:17PM +0200, Jiri Kosina wrote:
>On Mon, 16 Apr 2018, Sasha Levin wrote:
>
>> So if a user is operating a nuclear power plant, and has 2 leds: green
>> one that says "All OK!" and a red one saying "NUCLEAR MELTDOWN!", and
>> once in a blue moon a race condition is causing the red one to go on and
>> cause panic in the little province he lives in, we should tell that user
>> to fuck off?
>>
>> LEDs may not be critical for you, but they can be critical for someone
>> else. Think of all the different users we have and the wildly different
>> ways they use the kernel.
>
>I am pretty sure that for almost every fix there is a person on a planet
>that'd rate it "critical". We can't really use this as an argument for
>inclusion of code into -stable, as that'd mean that -stable and Linus'

So I think that Linus's claim that users come first applies here as
well. If there's a user that cares about a particular feature being
broken, then we go ahead and fix his bug rather then ignoring him.

>tree would have to be basically the same.

Basically the same minus all new features/subsystems/arch/etc. But yes,
ideally we'd want all bugfixes that go in mainline. Who not?

Instead of keeping bug fixes out, we need to work on improving our
testing story. Instead of ignoring that "person that'd rate it critical"
we should add his usecase into our testing matrix.=
