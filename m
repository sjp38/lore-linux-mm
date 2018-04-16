Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E30B6B0012
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:09:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e14so9772469pfi.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:09:42 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0097.outbound.protection.outlook.com. [104.47.32.97])
        by mx.google.com with ESMTPS id c129si9771904pga.456.2018.04.16.10.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 10:09:41 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Mon, 16 Apr 2018 17:09:38 +0000
Message-ID: <20180416170936.GI2341@sasha-vm>
References: <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd> <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm> <20180416163952.GA8740@amd>
 <20180416164310.GF2341@sasha-vm> <20180416125307.0c4f6f28@gandalf.local.home>
In-Reply-To: <20180416125307.0c4f6f28@gandalf.local.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4CDB12CF0C4C3D409CA5A741DA011A90@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, Apr 16, 2018 at 12:53:07PM -0400, Steven Rostedt wrote:
>On Mon, 16 Apr 2018 16:43:13 +0000
>Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>
>> >If you are worried about people not putting enough "Stable: " tags in
>> >their commits, perhaps you can write them emails "hey, I think this
>> >should go to stable, do you agree"? You should get people marking
>> >their commits themselves pretty quickly...
>>
>> Greg has been doing this for years, ask him how that worked out for him.
>
>Then he shouldn't pull in the fix. Let it be broken. As soon as someone
>complains about it being broken, then bug the maintainer again. "Hey,
>this is broken in 4.x, and this looks like the fix for it. Do you
>agree?"

If that process would work, I would also get ACK/NACK on every AUTOSEL
request I'm sending.

What usually happens with customer reported issues is that either
they're just told to upgrade to the latest kernel (where the bug is
fixed), or if the distro team can't get them to do that and go hunting
for that bug, they'll just pick it for their kernel tree without ever
telling -stable.

I had a project to get all the fixes Cannonical had in their trees that
we're not in -stable. We're talking hundreds of patches here.

>I agree that some patches don't need this discussion. Things that are
>obvious. Off-by-one and stack-overflow and other bugs like that. Or
>another common bug is error paths that don't release locks. These
>should just be backported. But subtle fixes like this thread should
>default to (not backport unless someones complains or the
>author/maintainer acks it).

Let's play a "be the -stable maintainer" game. Would you take any
of the following commits?

https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/com=
mit?id=3Dfc90441e728aa461a8ed1cfede08b0b9efef43fb
https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/com=
mit?id=3Da918d2bcea6aab6e671bfb0901cbecc3cf68fca1
https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/com=
mit?id=3Db1999fa6e8145305a6c8bda30ea20783717708e6
