Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id C78926B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:40:07 -0400 (EDT)
Received: by iget9 with SMTP id t9so97343985ige.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:40:07 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id h36si19736488iod.13.2015.04.28.15.40.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:40:07 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so97266913igb.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:40:07 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:40:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/9] mm: oom_kill: generalize OOM progress waitqueue
In-Reply-To: <1430161555-6058-5-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1504281539520.10203@chino.kir.corp.google.com>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org> <1430161555-6058-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 27 Apr 2015, Johannes Weiner wrote:

> It turns out that the mechanism to wait for exiting OOM victims is
> less generic than it looks: it won't issue wakeups unless the OOM
> killer is disabled.
> 
> The reason this check was added was the thought that, since only the
> OOM disabling code would wait on this queue, wakeup operations could
> be saved when that specific consumer is known to be absent.
> 
> However, this is quite the handgrenade.  Later attempts to reuse the
> waitqueue for other purposes will lead to completely unexpected bugs
> and the failure mode will appear seemingly illogical.  Generally,
> providers shouldn't make unnecessary assumptions about consumers.
> 
> This could have been replaced with waitqueue_active(), but it only
> saves a few instructions in one of the coldest paths in the kernel.
> Simply remove it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
