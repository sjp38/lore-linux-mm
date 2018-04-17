Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9BD66B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:22:55 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 61-v6so12468945plz.20
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:22:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8si7585093pgu.535.2018.04.17.07.22.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 07:22:54 -0700 (PDT)
Date: Tue, 17 Apr 2018 16:22:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417142246.GH17484@dhcp22.suse.cz>
References: <20180416161412.GZ2341@sasha-vm>
 <20180416122244.146aec48@gandalf.local.home>
 <20180416163107.GC2341@sasha-vm>
 <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm>
 <20180416170010.GA11034@amd>
 <20180417104637.GD8445@kroah.com>
 <20180417122454.rwkwpsfvyhpzvvx3@pathway.suse.cz>
 <20180417124924.GE17484@dhcp22.suse.cz>
 <20180417133931.GS2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417133931.GS2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Petr Mladek <pmladek@suse.com>, Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 17-04-18 13:39:33, Sasha Levin wrote:
[...]
> But mm/ commits don't come only from these people. Here's a concrete
> example we can discuss:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c61611f70958d86f659bca25c02ae69413747a8d

I would be really careful. Because that reqiures to audit all callers to
be compliant with the change. This is just _too_ easy to backport
without noticing a failure. Now consider the other side. Is there any
real bug report backing this? This behavior was like that for quite some
time but I do not remember any actual bug report and the changelog
doesn't mention one either. It is about theoretical problem. 

So if this was to be merged to stable then the changelog should contain
a big fat warning about the existing users and how they should be
checked.

Besides that I can see Reviewed-by: akpm and Andrew is usually very
careful about stable backports so there probably _was_ a reson to
exclude stable.
-- 
Michal Hocko
SUSE Labs
