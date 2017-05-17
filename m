Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1616B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 17:36:06 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id n14so375585uaj.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:36:06 -0700 (PDT)
Received: from mail-vk0-x242.google.com (mail-vk0-x242.google.com. [2607:f8b0:400c:c05::242])
        by mx.google.com with ESMTPS id w185si1265976vka.86.2017.05.17.14.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 14:36:05 -0700 (PDT)
Received: by mail-vk0-x242.google.com with SMTP id h16so1742530vkd.0
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:36:05 -0700 (PDT)
Date: Wed, 17 May 2017 17:36:03 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 08/17] cgroup: Move debug cgroup to its own file
Message-ID: <20170517213603.GE942@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-9-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494855256-12558-9-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Mon, May 15, 2017 at 09:34:07AM -0400, Waiman Long wrote:
> The debug cgroup currently resides within cgroup-v1.c and is enabled
> only for v1 cgroup. To enable the debug cgroup also for v2, it
> makes sense to put the code into its own file as it will no longer
> be v1 specific. The only change in this patch is the expansion of
> cgroup_task_count() within the debug_taskcount_read() function.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

I don't mind enabling the debug controller for v2 but let's please
hide it behind an unwieldy boot param / controller name so that it's
clear that its interface isn't expected to be stable.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
