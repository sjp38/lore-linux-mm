Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAE5B6B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 09:46:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a21so2929553pfo.8
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 06:46:03 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0118.outbound.protection.outlook.com. [104.47.36.118])
        by mx.google.com with ESMTPS id 90-v6si14622816plf.340.2018.04.17.06.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 06:46:02 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Date: Tue, 17 Apr 2018 13:45:59 +0000
Message-ID: <20180417134557.GT2341@sasha-vm>
References: <20180416155031.GX2341@sasha-vm> <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm> <20180416122244.146aec48@gandalf.local.home>
 <20180416163107.GC2341@sasha-vm> <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm> <20180416170010.GA11034@amd>
 <20180417104637.GD8445@kroah.com>
 <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
In-Reply-To: <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B492D29AE9069C41B15865E8EF17093B@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 17, 2018 at 02:24:54PM +0200, Petr Mladek wrote:
>Back to the trend. Last week I got autosel mails even for
>patches that were still being discussed, had issues, and
>were far from upstream:
>
> https://lkml.kernel.org/r/DM5PR2101MB1032AB19B489D46B717B50D4FBBB0@DM5PR2=
101MB1032.namprd21.prod.outlook.com
> https://lkml.kernel.org/r/DM5PR2101MB10327FA0A7E0D2C901E33B79FBBB0@DM5PR2=
101MB1032.namprd21.prod.outlook.com
>
>It might be a good idea if the mail asked to add Fixes: tag
>or stable mailing list. But the mail suggested to add the
>unfinished patch into stable branch directly (even before
>upstreaming?).

I obviously didn't suggest that this patch will go in -stable before
it's upstream.

I've started doing those because some folks can't be arsed to reply to a
review request for a patch that is months old. I found that if I send
these mails while the discussion is still going on I'd get a much better
response rate from people.

If you think any of these patches should go in stable there were two
ways about it:

 - You end up adding the -stable tag yourself, and it would follow the
   usual route where Greg picks it up.
 - You reply to that mail, and the patch would wait in a list until my
   script notices it made it upstream, at which point it would get
   queued for stable.

>Now, there are only hand full of printk patches in each
>release, so it is still doable. I just do not understand
>how other maintainers, from much more busy subsystems,
>could cope with this trend.
>
>By other words. If you want to automatize patch nomination,
>you might need to automatize also patch review. Or you need
>to keep the patch rate low. This might mean to nominate
>only important and rather trivial fixes.

I also have an effort to help review the patches. See what I'm working
on for the xfs folks:

	https://lkml.org/lkml/2018/3/29/1113

Where in addition to build tests I'd also run each commit, for each
stable kernel through a set of xfstests and provide them along with the
mail.

So yes, I'm aware that the volume of patches is huge, but there's not
much I can do about it because it's just a subset of the kernel's patch
volume and since the kernel gets more and more patches each release, the
volume of stable commits is bound to grow as well.=
