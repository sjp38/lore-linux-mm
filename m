Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 88C0D82F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 15:45:39 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so266866099wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:45:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ga17si621162wic.55.2015.09.24.12.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 12:45:38 -0700 (PDT)
Date: Thu, 24 Sep 2015 15:45:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, oom: remove task_lock protecting comm printing
Message-ID: <20150924194528.GB3009@cmpxchg.org>
References: <alpine.DEB.2.10.1509221629440.7794@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1509221629440.7794@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue, Sep 22, 2015 at 04:30:13PM -0700, David Rientjes wrote:
> The oom killer takes task_lock() in a couple of places solely to protect
> printing the task's comm.
> 
> A process's comm, including current's comm, may change due to
> /proc/pid/comm or PR_SET_NAME.
> 
> The comm will always be NULL-terminated, so the worst race scenario would
> only be during update.  We can tolerate a comm being printed that is in
> the middle of an update to avoid taking the lock.
> 
> Other locations in the kernel have already dropped task_lock() when
> printing comm, so this is consistent.
> 
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
