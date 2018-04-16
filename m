Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C097B6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:28:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z13so10062123pfe.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:28:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34-v6si13068240pln.473.2018.04.16.14.28.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 14:28:52 -0700 (PDT)
Date: Mon, 16 Apr 2018 23:28:44 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
In-Reply-To: <20180416211845.GP2341@sasha-vm>
Message-ID: <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
References: <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com> <20180416153031.GA5039@amd> <20180416155031.GX2341@sasha-vm> <20180416160608.GA7071@amd> <20180416161412.GZ2341@sasha-vm> <20180416170501.GB11034@amd> <20180416171607.GJ2341@sasha-vm>
 <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm> <20180416203629.GO2341@sasha-vm> <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm> <20180416211845.GP2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, 16 Apr 2018, Sasha Levin wrote:

> I agree that as an enterprise distro taking everything from -stable
> isn't the best idea. Ideally you'd want to be close to the first
> extreme you've mentioned and only take commits if customers are asking
> you to do so.
> 
> I think that the rule we're trying to agree upon is the "It must fix
> a real bug that bothers people".
> 
> I think that we can agree that it's impossible to expect every single
> Linux user to go on LKML and complain about a bug he encountered, so the
> rule quickly becomes "It must fix a real bug that can bother people".

So is there a reason why stable couldn't become some hybrid-form union of

- really critical issues (data corruption, boot issues, severe security 
  issues) taken from bleeding edge upstream
- [reviewed] cherry-picks of functional fixes from major distro kernels 
  (based on that very -stable release), as that's apparently what people 
  are hitting in the real world with that particular kernel

?

Thanks,

-- 
Jiri Kosina
SUSE Labs
