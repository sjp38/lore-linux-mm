Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDF716B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 17:40:38 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id g187so14214468ybf.12
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:40:38 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id d128si1042832ywe.309.2017.05.17.14.40.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 14:40:37 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id p144so1740745ywp.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:40:36 -0700 (PDT)
Date: Wed, 17 May 2017 17:40:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 09/17] cgroup: Keep accurate count of tasks in
 each css_set
Message-ID: <20170517214034.GF942@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-10-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494855256-12558-10-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Mon, May 15, 2017 at 09:34:08AM -0400, Waiman Long wrote:
> The reference count in the css_set data structure was used as a
> proxy of the number of tasks attached to that css_set. However, that
> count is actually not an accurate measure especially with thread mode
> support. So a new variable task_count is added to the css_set to keep
> track of the actual task count. This new variable is protected by
> the css_set_lock. Functions that require the actual task count are
> updated to use the new variable.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

Looks good.  We probably should replace css_set_populated() to use
this too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
