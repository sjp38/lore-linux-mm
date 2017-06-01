Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7D96B02FD
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 16:52:06 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id d80so35351041ywb.14
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 13:52:06 -0700 (PDT)
Received: from mail-yw0-x22f.google.com (mail-yw0-x22f.google.com. [2607:f8b0:4002:c05::22f])
        by mx.google.com with ESMTPS id v14si6741026ywv.142.2017.06.01.13.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 13:52:05 -0700 (PDT)
Received: by mail-yw0-x22f.google.com with SMTP id l74so25486577ywe.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 13:52:05 -0700 (PDT)
Date: Thu, 1 Jun 2017 16:52:03 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170601205203.GB13390@htj.duckdns.org>
References: <20170524203616.GO24798@htj.duckdns.org>
 <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
 <20170524212745.GP24798@htj.duckdns.org>
 <20170601145042.GA3494@htj.duckdns.org>
 <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
 <ffa991a3-074d-ffd5-7a6a-556d6cdd08fe@redhat.com>
 <20170601184740.GC3494@htj.duckdns.org>
 <ca834386-c41c-2797-702f-91516b06779f@redhat.com>
 <20170601203815.GA13390@htj.duckdns.org>
 <e65745c2-3b07-eb8b-b638-04e9bb1ed1e6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e65745c2-3b07-eb8b-b638-04e9bb1ed1e6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Thu, Jun 01, 2017 at 04:48:48PM -0400, Waiman Long wrote:
> I think we are on agreement here. I should we should just document how
> userland can work around the internal process competition issue by
> setting up the cgroup hierarchy properly. Then we can remove the no
> internal process constraint.

Heh, we agree on the immediate solution but not the final direction.
This requirement affects how controllers implement resource control in
significant ways.  It is a restriction which can be worked around in
userland relatively easily.  I'd much prefer to keep the invariant
intact.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
