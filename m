Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 704566B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:40:25 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so33820298ied.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:40:25 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id f192si19736407iof.16.2015.04.28.15.40.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:40:25 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so33620056igb.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:40:24 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:40:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/9] mm: oom_kill: remove unnecessary locking in
 exit_oom_victim()
In-Reply-To: <1430161555-6058-6-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1504281540100.10203@chino.kir.corp.google.com>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org> <1430161555-6058-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 27 Apr 2015, Johannes Weiner wrote:

> Disabling the OOM killer needs to exclude allocators from entering,
> not existing victims from exiting.
> 
> Right now the only waiter is suspend code, which achieves quiescence
> by disabling the OOM killer.  But later on we want to add waits that
> hold the lock instead to stop new victims from showing up.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
