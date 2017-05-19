Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0DE22806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 15:21:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p74so62609922pfd.11
        for <linux-mm@kvack.org>; Fri, 19 May 2017 12:21:50 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id h89si9019839pld.136.2017.05.19.12.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 12:21:49 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id u26so10430385pfd.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 12:21:49 -0700 (PDT)
Date: Fri, 19 May 2017 15:21:46 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 08/17] cgroup: Move debug cgroup to its own file
Message-ID: <20170519192146.GA9741@wtj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-9-git-send-email-longman@redhat.com>
 <20170517213603.GE942@htj.duckdns.org>
 <ee36d4f8-9e9d-a5c7-2174-56c21aaf75af@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ee36d4f8-9e9d-a5c7-2174-56c21aaf75af@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Thu, May 18, 2017 at 11:52:18AM -0400, Waiman Long wrote:
> The controller name is "debug" and so it is obvious what this controller
> is for. However, the config prompt "Example controller" is indeed vague

Yeah but it also shows up as an integral part of stable interface
rather than e.g. /sys/kernel/debug.  This isn't of any interest to
people who aren't developing cgroup core code.  There is no reason to
risk growing dependencies on it.

> in meaning. So we can make the prompt more descriptive here. As for the
> boot param, are you saying something like "cgroup_debug" has to be
> specified in the command line even if CGROUP_DEBUG config is there for
> the debug controller to be enabled? I am fine with that if you think it
> is necessary.

Yeah, I think that'd be a good idea.  cgroup_debug should do.  While
at it, can you also please make CGROUP_DEBUG depend on DEBUG_KERNEL?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
