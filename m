Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23D1B6B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 15:24:00 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id f204so630293ywc.15
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:24:00 -0700 (PDT)
Received: from mail-yb0-x242.google.com (mail-yb0-x242.google.com. [2607:f8b0:4002:c09::242])
        by mx.google.com with ESMTPS id k8si940161ywc.426.2017.05.17.12.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 12:23:59 -0700 (PDT)
Received: by mail-yb0-x242.google.com with SMTP id n198so765011yba.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:23:59 -0700 (PDT)
Date: Wed, 17 May 2017 15:23:57 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 07/17] cgroup: Prevent kill_css() from being
 called more than once
Message-ID: <20170517192357.GC942@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-8-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494855256-12558-8-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Mon, May 15, 2017 at 09:34:06AM -0400, Waiman Long wrote:
> The kill_css() function may be called more than once under the condition
> that the css was killed but not physically removed yet followed by the
> removal of the cgroup that is hosting the css. This patch prevents any
> harmm from being done when that happens.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

So, this is a bug fix which isn't really related to this patchset.
I'm applying it to cgroup/for-4.12-fixes w/ stable cc'd.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
