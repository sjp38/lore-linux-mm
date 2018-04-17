Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF85C6B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:21:26 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i4so16105118wrh.4
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 04:21:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g91si2519001edd.445.2018.04.17.04.21.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 04:21:25 -0700 (PDT)
Date: Tue, 17 Apr 2018 13:21:21 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
In-Reply-To: <20180417103936.GC8445@kroah.com>
Message-ID: <nycvar.YFH.7.76.1804171250270.28129@cbobk.fhfr.pm>
References: <20180416155031.GX2341@sasha-vm> <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm> <20180416170501.GB11034@amd> <20180416171607.GJ2341@sasha-vm> <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm> <20180416203629.GO2341@sasha-vm>
 <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm> <20180416211845.GP2341@sasha-vm> <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm> <20180417103936.GC8445@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, 17 Apr 2018, Greg KH wrote:

> It already is that :)

I have a question: I guess a stable team has an idea who they are 
preparing the tree for, IOW who is the target consumer. Who is it?

Certainly it's not major distros, as both RH and SUSE already stated that 
they are either not basing off the stable kernel (only cherry-pick fixes 
from it) (RH), or are quite far in the process of moving away from stable 
tree towards combination of what RH is doing + semi-automated evaluation 
of Fixes: tag (SUSE).

If the target audience is somewhere else, that's perfectly fine, but then 
it'd have to be stated explicitly I guess.

I can't speak for RH, but for us (at least me personally), the pace of 
patches flowing into -stable is way too high for us to keep control of 
what is landing in our tree.

In some sense, stability should be equivalent to "minimal necessary amout 
of super-critical changes". That's not what this "let's backport 
proactively almost everything that has word 'fixes' in changelog" (I'm a 
bit exaggerating of course) seems to be about.

Again, the rules stated out in

	Documentation/process/stable-kernel-rules.rst

are very nice, and are exactly something at least we would be very happy 
about. They have the nice hidden asumption in them, that someone actually 
has to actively invest human brain power to think about the fix, its 
consequences, prerequisities, etc. Not just doing a big dump of all 
commits that "might fix something".

How many of the actual patches flowing into -stable would satisfy those 
criteria these days?

IOW, I'm pretty sure our users are much happier with us supplying them 
reactive fixes than pro-active uncertainity.

> The problem Sasha is trying to solve here is that for many subsystems,
> maintainers do not mark patches for stable at all.

The pressure on those subsystems should be coming from unhappy users 
(being it end-users or vendors redistributing the tree) of the stable 
tree, who would be complaining about missing fixes for those subsystems. 
Is this actually happening? Where?

> Oh, and if you do want to complain about huge new features being 
> backported, look at the mess that Spectre and Meltdown has caused in the 
> stable trees.  I don't see anyone complaining about those massive 
> changes :)

Umm, sorry, how is this related?

There simply was no other way, and I took it for given that this is seen 
by everybody involved as an absolute exception, due to the nature of the 
issue and of the massive changes that were needed.

Thanks,

-- 
Jiri Kosina
SUSE Labs
