Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 789386B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 09:39:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b16so11404862pfi.5
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 06:39:38 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0120.outbound.protection.outlook.com. [104.47.34.120])
        by mx.google.com with ESMTPS id t22-v6si13828149plj.595.2018.04.17.06.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 06:39:37 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Tue, 17 Apr 2018 13:39:33 +0000
Message-ID: <20180417133931.GS2341@sasha-vm>
References: <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm>
 <20180416122244.146aec48@gandalf.local.home> <20180416163107.GC2341@sasha-vm>
 <20180416124711.048f1858@gandalf.local.home> <20180416165258.GH2341@sasha-vm>
 <20180416170010.GA11034@amd> <20180417104637.GD8445@kroah.com>
 <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
 <20180417124924.GE17484@dhcp22.suse.cz>
In-Reply-To: <20180417124924.GE17484@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <0DDD0234E682F2419DBE62CF9CA460FD@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 17, 2018 at 02:49:24PM +0200, Michal Hocko wrote:
>On Tue 17-04-18 14:24:54, Petr Mladek wrote:
>[...]
>> Back to the trend. Last week I got autosel mails even for
>> patches that were still being discussed, had issues, and
>> were far from upstream:
>>
>> https://lkml.kernel.org/r/DM5PR2101MB1032AB19B489D46B717B50D4FBBB0@DM5PR=
2101MB1032.namprd21.prod.outlook.com
>> https://lkml.kernel.org/r/DM5PR2101MB10327FA0A7E0D2C901E33B79FBBB0@DM5PR=
2101MB1032.namprd21.prod.outlook.com
>>
>> It might be a good idea if the mail asked to add Fixes: tag
>> or stable mailing list. But the mail suggested to add the
>> unfinished patch into stable branch directly (even before
>> upstreaming?).
>
>Well, I think that poking subsystems which ignore stable trees with such
>emails early during review might be quite helpful. Maybe people start
>marking for stable and we do not need the guessing later. I wouldn't
>bother poking those who are known to mark stable patches though.

Yup, mm/ needs far less poking that XFS (for example).

What makes mm/ so good about this is that it's a rather small set of
devs who are good at marking things for stable. As long as the commit
came from one of these "core" mm/ folks it's almost guaranteed to have
proper stable tags.

But mm/ commits don't come only from these people. Here's a concrete
example we can discuss:

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?=
id=3Dc61611f70958d86f659bca25c02ae69413747a8d

This was merged in a few days ago, and seems relevant for older kernel
trees as well. Should it not have a stable tag?=
