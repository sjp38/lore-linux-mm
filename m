Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91A4F6B02C3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:41:28 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d14so19082373qkb.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:41:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t66si20284228qkf.279.2017.06.01.11.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:41:27 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
 <20170524203616.GO24798@htj.duckdns.org>
 <9b147a7e-fec3-3b78-7587-3890efcd42f2@redhat.com>
 <20170524212745.GP24798@htj.duckdns.org>
 <20170601145042.GA3494@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <9e95a3b2-2922-f5f7-f424-7ae0639b6e68@redhat.com>
Date: Thu, 1 Jun 2017 14:41:24 -0400
MIME-Version: 1.0
In-Reply-To: <20170601145042.GA3494@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 06/01/2017 10:50 AM, Tejun Heo wrote:
> Hello, Waiman.
>
> A short update.  I tried making root special while keeping the
> existing threaded semantics but I didn't really like it because we
> have to couple controller enables/disables with threaded
> enables/disables.  I'm now trying a simpler, albeit a bit more
> tedious, approach which should leave things mostly symmetrical.  I'm
> hoping to be able to post mostly working patches this week.

I am looking forward to your patches.

> Also, do you mind posting the debug patches as a separate series?
> Let's get the bits which make sense indepdently in the tree.

I am going to do that. The debug patches, however, will have dependency
on other cgroup patches and so will need to be posted after the core
patches.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
