Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED18E6B000A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:16:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17so9750670pfn.10
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:16:13 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0139.outbound.protection.outlook.com. [104.47.32.139])
        by mx.google.com with ESMTPS id h61-v6si12255863pld.152.2018.04.16.10.16.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 10:16:12 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 17:16:10 +0000
Message-ID: <20180416171607.GJ2341@sasha-vm>
References: <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm>
 <20180416170501.GB11034@amd>
In-Reply-To: <20180416170501.GB11034@amd>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <0C3B5C414C03DB4A8A65FCFF3F66FA70@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Apr 16, 2018 at 07:05:01PM +0200, Pavel Machek wrote:
>Hi!
>
>> How do you know if a bug bothers someone?
>>
>> If a user is annoyed by a LED issue, is he expected to triage the bug,
>> report it on LKML and patiently wait for the appropriate patch to be
>> backported?
>
>If the user is annoyed by a LED issue, you are actually expected to
>tell him that it is not going to be fixed, because it is not on the list:
>
> - It must fix a problem that causes a build error (but not for things
>    marked CONFIG_BROKEN), an oops, a hang, data corruption, a real
>    security issue, or some "oh, that's not good" issue.  In short,
>    something critical.

So if a user is operating a nuclear power plant, and has 2 leds: green
one that says "All OK!" and a red one saying "NUCLEAR MELTDOWN!", and
once in a blue moon a race condition is causing the red one to go on and
cause panic in the little province he lives in, we should tell that user
to fuck off?

LEDs may not be critical for you, but they can be critical for someone
else. Think of all the different users we have and the wildly different
ways they use the kernel.=
