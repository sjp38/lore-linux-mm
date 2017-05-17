Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id D147C6B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 15:20:22 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id y134so12265336yby.11
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:20:22 -0700 (PDT)
Received: from mail-yb0-x241.google.com (mail-yb0-x241.google.com. [2607:f8b0:4002:c09::241])
        by mx.google.com with ESMTPS id o65si970640ywd.446.2017.05.17.12.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 12:20:21 -0700 (PDT)
Received: by mail-yb0-x241.google.com with SMTP id c207so761872ybf.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:20:21 -0700 (PDT)
Date: Wed, 17 May 2017 15:20:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 06/17] cgroup: Fix reference counting bug in
 cgroup_procs_write()
Message-ID: <20170517192019.GB942@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-7-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494855256-12558-7-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On Mon, May 15, 2017 at 09:34:05AM -0400, Waiman Long wrote:
> The cgroup_procs_write_start() took a reference to the task structure
> which was not properly released within cgroup_procs_write() and so
> on. So a put_task_struct() call is added to cgroup_procs_write_finish()
> to match the get_task_struct() in cgroup_procs_write_start() to fix
> this reference counting error.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
