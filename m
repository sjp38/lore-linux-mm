Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B64256B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 22:10:44 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d6-v6so2211949plo.15
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 19:10:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r73-v6si4820644pgr.500.2018.06.27.19.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 19:10:43 -0700 (PDT)
Date: Wed, 27 Jun 2018 19:10:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 2/2] Refactor part of the oom report in dump_header
Message-Id: <20180627191041.509893a3b43f95a27df32266@linux-foundation.org>
In-Reply-To: <1529763171-29240-2-git-send-email-ufo19890607@gmail.com>
References: <1529763171-29240-1-git-send-email-ufo19890607@gmail.com>
	<1529763171-29240-2-git-send-email-ufo19890607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Sat, 23 Jun 2018 22:12:51 +0800 ufo19890607@gmail.com wrote:

> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The current system wide oom report prints information about the victim
> and the allocation context and restrictions. It, however, doesn't
> provide any information about memory cgroup the victim belongs to. This
> information can be interesting for container users because they can find
> the victim's container much more easily.
> 
> I follow the advices of David Rientjes and Michal Hocko, and refactor
> part of the oom report. After this patch, users can get the memcg's
> path from the oom report and check the certain container more quickly.
> 
> The oom print info after this patch:
> oom-kill:constraint=<constraint>,nodemask=<nodemask>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<commm>,pid=<pid>,uid=<uid>
> 
> Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
> ---
> Below is the part of the oom report in the dmesg
> ...
> [  134.873392] panic invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
>
> ...
>
> [  134.873480] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),task_memcg=/test/test1/test2,task=panic,pid= 8669,  uid=    0

We're displaying nodemask twice there.  Avoidable?

Also, the spaces after pid= and uid= don't seem useful.  Why not use
plain old %d?
