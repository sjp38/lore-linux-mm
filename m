Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 277356B02F3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 17:12:47 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d14so20429177qkb.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 14:12:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q77si4286209qka.83.2017.06.01.14.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 14:12:46 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
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
 <20170601205203.GB13390@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <1e775dcf-61b2-29d5-a214-350dc81c632b@redhat.com>
Date: Thu, 1 Jun 2017 17:12:42 -0400
MIME-Version: 1.0
In-Reply-To: <20170601205203.GB13390@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 06/01/2017 04:52 PM, Tejun Heo wrote:
> Hello,
>
> On Thu, Jun 01, 2017 at 04:48:48PM -0400, Waiman Long wrote:
>> I think we are on agreement here. I should we should just document how=

>> userland can work around the internal process competition issue by
>> setting up the cgroup hierarchy properly. Then we can remove the no
>> internal process constraint.
> Heh, we agree on the immediate solution but not the final direction.
> This requirement affects how controllers implement resource control in
> significant ways.  It is a restriction which can be worked around in
> userland relatively easily.  I'd much prefer to keep the invariant
> intact.
>
> Thanks.
>
Are you referring to keeping the no internal process restriction and
document how to work around that instead? I would like to hear what
workarounds are currently being used.

Anyway, you currently allow internal process in thread mode, but not in
non-thread mode. I would prefer no such restriction in both thread and
non-thread mode.

Cheers,
Longman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
