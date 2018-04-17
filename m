Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8E226B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:49:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v11so16297825wri.13
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 05:49:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si207284edm.135.2018.04.17.05.49.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 05:49:28 -0700 (PDT)
Date: Tue, 17 Apr 2018 14:49:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417124924.GE17484@dhcp22.suse.cz>
References: <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416122244.146aec48@gandalf.local.home>
 <20180416163107.GC2341@sasha-vm>
 <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm>
 <20180416170010.GA11034@amd>
 <20180417104637.GD8445@kroah.com>
 <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Sasha Levin <Alexander.Levin@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 17-04-18 14:24:54, Petr Mladek wrote:
[...]
> Back to the trend. Last week I got autosel mails even for
> patches that were still being discussed, had issues, and
> were far from upstream:
> 
> https://lkml.kernel.org/r/DM5PR2101MB1032AB19B489D46B717B50D4FBBB0@DM5PR2101MB1032.namprd21.prod.outlook.com
> https://lkml.kernel.org/r/DM5PR2101MB10327FA0A7E0D2C901E33B79FBBB0@DM5PR2101MB1032.namprd21.prod.outlook.com
> 
> It might be a good idea if the mail asked to add Fixes: tag
> or stable mailing list. But the mail suggested to add the
> unfinished patch into stable branch directly (even before
> upstreaming?).

Well, I think that poking subsystems which ignore stable trees with such
emails early during review might be quite helpful. Maybe people start
marking for stable and we do not need the guessing later. I wouldn't
bother poking those who are known to mark stable patches though.
-- 
Michal Hocko
SUSE Labs
