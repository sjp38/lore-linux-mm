Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F61C6B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 13:01:46 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id b40so48935322ybj.15
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:01:46 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id j3si8339783ywk.186.2017.05.24.10.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 10:01:45 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id 17so13193054ywk.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 10:01:45 -0700 (PDT)
Date: Wed, 24 May 2017 13:01:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 12/17] cgroup: Remove cgroup v2 no internal
 process constraint
Message-ID: <20170524170140.GG24798@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-13-git-send-email-longman@redhat.com>
 <20170519203824.GC15279@wtj.duckdns.org>
 <1495246207.7442.2.camel@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495246207.7442.2.camel@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Waiman Long <longman@redhat.com>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net

Hello, Mike.

On Sat, May 20, 2017 at 04:10:07AM +0200, Mike Galbraith wrote:
> On Fri, 2017-05-19 at 16:38 -0400, Tejun Heo wrote:
> > Hello, Waiman.
> > 
> > On Mon, May 15, 2017 at 09:34:11AM -0400, Waiman Long wrote:
> > > The rationale behind the cgroup v2 no internal process constraint is
> > > to avoid resouorce competition between internal processes and child
> > > cgroups. However, not all controllers have problem with internal
> > > process competiton. Enforcing this rule may lead to unnatural process
> > > hierarchy and unneeded levels for those controllers.
> > 
> > This isn't necessarily something we can determine by looking at the
> > current state of controllers.  It's true that some controllers - pid
> > and perf - inherently only care about membership of each task but at
> > the same time neither really suffers from the constraint either.  CPU
> > which is the problematic one here...
> 
> (+ cpuacct + cpuset)

Yeah, cpuacct and cpuset are in the same boat as perf.  cpuset is
completely so and we can move the tree walk to the reader side or
aggregate propagation for cpuacct as necessary.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
