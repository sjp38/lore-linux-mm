Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38FE56B0009
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:52:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t3so1466602pgc.21
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:52:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4si11827393pgp.558.2018.04.17.08.52.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 08:52:38 -0700 (PDT)
Date: Tue, 17 Apr 2018 17:52:30 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
In-Reply-To: <20180417145531.GW2341@sasha-vm>
Message-ID: <nycvar.YFH.7.76.1804171742450.28129@cbobk.fhfr.pm>
References: <20180416171607.GJ2341@sasha-vm> <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm> <20180416203629.GO2341@sasha-vm> <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm> <20180416211845.GP2341@sasha-vm> <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
 <20180417103936.GC8445@kroah.com> <20180417110717.GB17484@dhcp22.suse.cz> <20180417140434.GU2341@sasha-vm> <20180417143631.GI17484@dhcp22.suse.cz> <20180417145531.GW2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg KH <greg@kroah.com>, Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, 17 Apr 2018, Sasha Levin wrote:

> How do I get the XFS folks to send their stuff to -stable? (we have
> quite a few customers who use XFS)

If XFS (or *any* other subsystem) doesn't have enough manpower of upstream 
maintainers to deal with stable, we just have to accept that and find an 
answer to that.

If XFS folks claim that they don't have enough mental capacity to 
create/verify XFS backports, I totally don't see how any kind of AI would 
have.

If your business relies on XFS (and so does ours, BTW) or any other 
subsystem that doesn't have enough manpower to care for stable, the proper 
solution (and contribution) would be just bringing more people into the 
XFS community.

To put it simply -- I don't think the simple lack of actual human 
brainpower can be reasonably resolved in other way than bringing more of 
it in.

Thanks,

-- 
Jiri Kosina
SUSE Labs
