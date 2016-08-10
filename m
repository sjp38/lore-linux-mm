Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA436B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 21:21:20 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id j12so52038042ywb.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 18:21:20 -0700 (PDT)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id p63si6503563ywp.232.2016.08.09.18.21.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 18:21:19 -0700 (PDT)
Received: by mail-yw0-x243.google.com with SMTP id j12so1325039ywb.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 18:21:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160809142603.GE4906@mtj.duckdns.org>
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
 <20160809062900.GD4906@mtj.duckdns.org> <0a7ffe43-c0c6-85df-9bc2-d00fc837e284@gmail.com>
 <20160809142603.GE4906@mtj.duckdns.org>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 10 Aug 2016 11:21:17 +1000
Message-ID: <CAKTCnzkXaZHaJVJGodphFRAnDfDzh9NKTYQqJ-90CMZ93epk3Q@mail.gmail.com>
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability and OOM
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Aug 10, 2016 at 12:26 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Balbir.
>
> On Tue, Aug 09, 2016 at 05:02:47PM +1000, Balbir Singh wrote:
>> > Hmm? Where does mem_cgroup_iter grab cgroup_mutex?  cgroup_mutex nests
>> > outside cgroup_threadgroup_rwsem or most other mutexes for that matter
>> > and isn't exposed from cgroup core.
>> >
>>
>> I based my theory on the code
>>
>> mem_cgroup_iter -> css_next_descendant_pre which asserts
>>
>> cgroup_assert_mutex_or_rcu_locked(),
>>
>> although you are right, we hold RCU lock while calling css_* routines.
>
> That's "or".  The iterator can be called either with RCU lock or
> cgroup_mutex.  cgroup core may use it under cgroup_mutex.  Everyone
> else uses it with rcu.
>
> Thanks.
>

Hi, Tejun

Thanks agreed! Could you please consider queuing the fix after review.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
