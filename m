Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 148D86B0271
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:36:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u11-v6so12455393pls.22
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:36:49 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0126.outbound.protection.outlook.com. [104.47.37.126])
        by mx.google.com with ESMTPS id u12-v6si11170995plm.83.2018.04.17.07.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 07:36:47 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Tue, 17 Apr 2018 14:36:44 +0000
Message-ID: <20180417143641.GV2341@sasha-vm>
References: <20180416122244.146aec48@gandalf.local.home>
 <20180416163107.GC2341@sasha-vm> <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm> <20180416170010.GA11034@amd>
 <20180417104637.GD8445@kroah.com>
 <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
 <20180417124924.GE17484@dhcp22.suse.cz> <20180417133931.GS2341@sasha-vm>
 <20180417142246.GH17484@dhcp22.suse.cz>
In-Reply-To: <20180417142246.GH17484@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A72F5632B207064A8FD41BFF577BDC68@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 17, 2018 at 04:22:46PM +0200, Michal Hocko wrote:
>On Tue 17-04-18 13:39:33, Sasha Levin wrote:
>[...]
>> But mm/ commits don't come only from these people. Here's a concrete
>> example we can discuss:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commi=
t/?id=3Dc61611f70958d86f659bca25c02ae69413747a8d
>
>I would be really careful. Because that reqiures to audit all callers to
>be compliant with the change. This is just _too_ easy to backport
>without noticing a failure. Now consider the other side. Is there any
>real bug report backing this? This behavior was like that for quite some
>time but I do not remember any actual bug report and the changelog
>doesn't mention one either. It is about theoretical problem.

https://lkml.org/lkml/2018/3/19/430

There's even a fun little reproducer that allowed me to confirm it's an
issue (at least) on 4.15.

Heck, it might even qualify as a CVE.

>So if this was to be merged to stable then the changelog should contain
>a big fat warning about the existing users and how they should be
>checked.

So what I'm asking is why *wasn't* it sent to stable? Yes, it requires
additional work backporting this, but what I'm saying is that this
didn't happen at all.

>Besides that I can see Reviewed-by: akpm and Andrew is usually very
>careful about stable backports so there probably _was_ a reson to
>exclude stable.
>--=20
>Michal Hocko
>SUSE Labs=
