Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC706B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 21:36:24 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so50759932pab.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 18:36:24 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id x67si45529454pff.126.2016.08.09.18.36.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 18:36:23 -0700 (PDT)
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability and
 OOM
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
 <57A99BCB.6070905@huawei.com> <20160809135703.GA11823@350D>
From: Zefan Li <lizefan@huawei.com>
Message-ID: <57AA83FE.1050809@huawei.com>
Date: Wed, 10 Aug 2016 09:31:42 +0800
MIME-Version: 1.0
In-Reply-To: <20160809135703.GA11823@350D>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bsingharora@gmail.com
Cc: cgroups@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>> For example, I'm trying to fix a race. See https://lkml.org/lkml/2016/8/8/900
>>
>> And the fix kind of relies on the fact that cgroup_post_fork() is placed
>> inside the read section of cgroup_threadgroup_rwsem, so that cpuset_fork()
>> won't race with cgroup migration.
>>
> 
> My patch retains that behaviour, before ss->fork() is called we hold
> the cgroup_threadgroup_rwsem, in fact it is held prior to ss->can_fork()
> 

I read the patch again and now I see only threadgroup_change_begin() is moved
downwards, and threadgroup_change_end() remains intact. Then I have no problem
with it.

Acked-by: Zefan Li <lizefan@huawei.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
