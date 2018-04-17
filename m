Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7DB6B000E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:06:35 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id t126-v6so12776184itc.1
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 09:06:35 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0110.outbound.protection.outlook.com. [104.47.33.110])
        by mx.google.com with ESMTPS id t188-v6si8037531itc.8.2018.04.17.09.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 09:06:34 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Tue, 17 Apr 2018 16:06:29 +0000
Message-ID: <20180417160627.GX2341@sasha-vm>
References: <20180416203629.GO2341@sasha-vm>
 <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
 <20180416211845.GP2341@sasha-vm>
 <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
 <20180417103936.GC8445@kroah.com> <20180417110717.GB17484@dhcp22.suse.cz>
 <20180417140434.GU2341@sasha-vm> <20180417143631.GI17484@dhcp22.suse.cz>
 <20180417145531.GW2341@sasha-vm>
 <nycvar.YFH.7.76.1804171742450.28129@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1804171742450.28129@cbobk.fhfr.pm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2DBF7BC322379548A28EE157D5D0E93D@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 17, 2018 at 05:52:30PM +0200, Jiri Kosina wrote:
>On Tue, 17 Apr 2018, Sasha Levin wrote:
>
>> How do I get the XFS folks to send their stuff to -stable? (we have
>> quite a few customers who use XFS)
>
>If XFS (or *any* other subsystem) doesn't have enough manpower of upstream
>maintainers to deal with stable, we just have to accept that and find an
>answer to that.

This is exactly what I'm doing. Many subsystems don't have enough
manpower to deal with -stable, so I'm trying to help.

>If XFS folks claim that they don't have enough mental capacity to
>create/verify XFS backports, I totally don't see how any kind of AI would
>have.

Because creating backports is not all about mental capacity!

A lot of time gets wasted on going through the list of commits,
backporting each of those commits into every -stable tree we have,
building it, running tests, etc.

So it's not all about pure mental capacity, but more about the time
per-patch it takes to get -stable done.

If I can cut down on that, by suggesting a list of commits, doing builds
and tests, what's the problem?

>If your business relies on XFS (and so does ours, BTW) or any other
>subsystem that doesn't have enough manpower to care for stable, the proper
>solution (and contribution) would be just bringing more people into the
>XFS community.

Microsoft's business relies on quite a few kernel subsystems. While we
try to bring more people in the kernel (we're hiring!), as you might
know it's not easy getting kernel folks.

So just "get more people" isn't a good solution. It doesn't scale
either.

>To put it simply -- I don't think the simple lack of actual human
>brainpower can be reasonably resolved in other way than bringing more of
>it in.
>
>Thanks,
>
>--=20
>Jiri Kosina
>SUSE Labs
>=
