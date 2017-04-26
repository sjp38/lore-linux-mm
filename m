Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 057536B02E1
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 18:30:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b17so9287461pfd.1
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 15:30:50 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id w5si624986pls.148.2017.04.26.15.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 15:30:50 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id c198so3257221pfc.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 15:30:49 -0700 (PDT)
Date: Wed, 26 Apr 2017 15:30:47 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 00/14] cgroup: Implement cgroup v2 thread mode & CPU
 controller
Message-ID: <20170426223047.GA11348@wtj.duckdns.org>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
 <fa35c889-85a8-8b85-c836-4c5070cd7cdc@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa35c889-85a8-8b85-c836-4c5070cd7cdc@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Wed, Apr 26, 2017 at 12:05:27PM -0400, Waiman Long wrote:
> Does anyone has time to take a look at these patches?
> 
> As the merge window is going to open up next week, I am not going to
> bother you guys when the merge window opens.

Will get to it next week.  Sorry about the delay.  We're deploying
cgroup2 across the fleet and seeing a lot of interesting issues and I
was chasing down CPU controller performance issues for the last month
or so, which is now getting wrapped up.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
