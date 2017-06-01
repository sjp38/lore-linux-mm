Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43D306B02F3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 17:18:26 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id 202so10904746ybd.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 14:18:26 -0700 (PDT)
Received: from mail-yb0-x229.google.com (mail-yb0-x229.google.com. [2607:f8b0:4002:c09::229])
        by mx.google.com with ESMTPS id o3si7068738ywf.118.2017.06.01.14.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 14:18:25 -0700 (PDT)
Received: by mail-yb0-x229.google.com with SMTP id 132so13827922ybq.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 14:18:25 -0700 (PDT)
Date: Thu, 1 Jun 2017 17:18:23 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170601211823.GC13390@htj.duckdns.org>
References: <20170524212745.GP24798@htj.duckdns.org>
 <20170601145042.GA3494@htj.duckdns.org>
 <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
 <ffa991a3-074d-ffd5-7a6a-556d6cdd08fe@redhat.com>
 <20170601184740.GC3494@htj.duckdns.org>
 <ca834386-c41c-2797-702f-91516b06779f@redhat.com>
 <20170601203815.GA13390@htj.duckdns.org>
 <e65745c2-3b07-eb8b-b638-04e9bb1ed1e6@redhat.com>
 <20170601205203.GB13390@htj.duckdns.org>
 <1e775dcf-61b2-29d5-a214-350dc81c632b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e775dcf-61b2-29d5-a214-350dc81c632b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Thu, Jun 01, 2017 at 05:12:42PM -0400, Waiman Long wrote:
> Are you referring to keeping the no internal process restriction and
> document how to work around that instead? I would like to hear what
> workarounds are currently being used.

What we've been talking about all along - just creating explicit leaf
nodes.

> Anyway, you currently allow internal process in thread mode, but not in
> non-thread mode. I would prefer no such restriction in both thread and
> non-thread mode.

Heh, so, these aren't arbitrary.  The contraint is tied to
implementing resource domains and thread subtree doesn't have resource
domains in them, so they don't need the constraint.  I'm sorry about
the short replies but I'm kinda really tied up right now.  I'm gonna
do the thread mode so that it can be agnostic w.r.t. the internal
process constraint and I think it could be helpful to decouple these
discussions.  We've been having this discussion for a couple years now
and it looks like we're gonna go through it all over, which is fine,
but let's at least keep that separate.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
