Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 866946B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:15:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w5-v6so2617054plz.17
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:15:07 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 72si13175288pfn.44.2018.04.17.07.15.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:15:06 -0700 (PDT)
Date: Tue, 17 Apr 2018 10:15:02 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417101502.3f61d958@gandalf.local.home>
In-Reply-To: <20180417140434.GU2341@sasha-vm>
References: <20180416161412.GZ2341@sasha-vm>
	<20180416170501.GB11034@amd>
	<20180416171607.GJ2341@sasha-vm>
	<alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
	<20180416203629.GO2341@sasha-vm>
	<nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
	<20180416211845.GP2341@sasha-vm>
	<nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
	<20180417103936.GC8445@kroah.com>
	<20180417110717.GB17484@dhcp22.suse.cz>
	<20180417140434.GU2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg KH <greg@kroah.com>, Jiri Kosina <jikos@kernel.org>, Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue, 17 Apr 2018 14:04:36 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

> The solution to this, in my opinion, is to automate the whole selection
> and review process. We do selection using AI, and we run every possible
> test that's relevant to that subsystem.
> 
> At which point, the amount of work a human needs to do to review a patch
> shrinks into something far more managable for some maintainers.

I guess the real question is, who are the stable kernels for? Is it just
a place to look at to see what distros should think about. A superset
of what distros would take. Then distros would have a nice place to
look to find what patches they should look at. But the stable tree
itself wont be used. But it's not being used today by major distros
(Red Hat and SuSE). Debian may be using it, but that's because the
stable maintainer for its kernels is also the Debian maintainer.

Who are the customers of the stable trees? They are the ones that
should be determining the "equation" for what goes into it.

Personally, I use stable as a one off from mainline. Like I mentioned
in another email. I'm currently on 4.15.x and will probably move to
4.16.x next. Unless there's some critical bug announcement, I update my
machines once a month. I originally just used mainline, but that was a
bit too unstable for my work machines ;-)

-- Steve
