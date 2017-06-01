Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC3F6B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:47:44 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id a132so20195197ywe.13
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:47:44 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id b8si814661yba.266.2017.06.01.11.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:47:43 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id p144so3302388ywp.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:47:43 -0700 (PDT)
Date: Thu, 1 Jun 2017 14:47:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170601184740.GC3494@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
 <20170524203616.GO24798@htj.duckdns.org>
 <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
 <20170524212745.GP24798@htj.duckdns.org>
 <20170601145042.GA3494@htj.duckdns.org>
 <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
 <ffa991a3-074d-ffd5-7a6a-556d6cdd08fe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffa991a3-074d-ffd5-7a6a-556d6cdd08fe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Thu, Jun 01, 2017 at 02:44:48PM -0400, Waiman Long wrote:
> > And cgroup-v2 has this 'exception' (aka wart) for the root group which
> > needs to be replicated for each namespace.
> 
> One of the changes that I proposed in my patches was to get rid of the
> no internal process constraint. I think that will solve a big part of
> the container invariant problem that we have with cgroup v2.

I'm not sure.  It just masks it without actually solving it.  I mean,
the constraint is thereq for a reason.  "Solving" it would defeat one
of the main capabilities for resource domains and masking it from
kernel side doesn't make whole lot of sense to me given that it's
something which can be easily done from userland.  If we take out that
part, for controllers which don't care about resource domains,
wouldn't thread mode be a sufficient solution?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
