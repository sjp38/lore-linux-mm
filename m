Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC59D6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 11:11:00 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id q81so44406924itc.9
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:11:00 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id f202si20665075itb.121.2017.06.01.08.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 08:10:59 -0700 (PDT)
Date: Thu, 1 Jun 2017 17:10:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170601151045.xhsv7jauejjis3mi@hirez.programming.kicks-ass.net>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
 <20170524203616.GO24798@htj.duckdns.org>
 <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
 <20170524212745.GP24798@htj.duckdns.org>
 <20170601145042.GA3494@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601145042.GA3494@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Waiman Long <longman@redhat.com>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On Thu, Jun 01, 2017 at 10:50:42AM -0400, Tejun Heo wrote:
> Hello, Waiman.
> 
> A short update.  I tried making root special while keeping the
> existing threaded semantics but I didn't really like it because we
> have to couple controller enables/disables with threaded
> enables/disables.  I'm now trying a simpler, albeit a bit more
> tedious, approach which should leave things mostly symmetrical.  I'm
> hoping to be able to post mostly working patches this week.

I've not had time to look at any of this. But the question I'm most
curious about is how cgroup-v2 preserves the container invariant.

That is, each container (namespace) should look like a 'real' machine.
So just like userns allows to have a uid-0 (aka root) for each container
and pidns allows a pid-1 for each container, cgroupns should provide a
root group for each container.

And cgroup-v2 has this 'exception' (aka wart) for the root group which
needs to be replicated for each namespace.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
