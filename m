Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A56FA6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:43:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id h12-v6so10863770pls.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:43:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z11-v6si3001462plo.278.2018.04.16.13.43.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 13:43:34 -0700 (PDT)
Date: Mon, 16 Apr 2018 22:43:28 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
In-Reply-To: <20180416203629.GO2341@sasha-vm>
Message-ID: <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
References: <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home> <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com> <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm> <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm> <20180416170501.GB11034@amd> <20180416171607.GJ2341@sasha-vm> <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm> <20180416203629.GO2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, 16 Apr 2018, Sasha Levin wrote:

> So I think that Linus's claim that users come first applies here as
> well. If there's a user that cares about a particular feature being
> broken, then we go ahead and fix his bug rather then ignoring him.

So one extreme is fixing -stable *iff* users actually do report an issue.

The other extreme is backporting everything that potentially looks like a 
potential fix of "something" (according to some arbitrary metric), 
pro-actively.

The former voilates the "users first" rule, the latter has a very, very 
high risk of regressions.

So this whole debate is about finding a compromise.

My gut feeling always was that the statement in

	Documentation/process/stable-kernel-rules.rst

is very reasonable, but making the process way more "aggresive" when 
backporting patches is breaking much of its original spirit for me.

-- 
Jiri Kosina
SUSE Labs
