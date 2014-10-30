Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6E08190008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 04:35:48 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id pn19so3944537lab.14
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 01:35:47 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id pi7si10961347lbb.15.2014.10.30.01.35.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 01:35:46 -0700 (PDT)
Date: Thu, 30 Oct 2014 09:35:44 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
Message-ID: <20141030083544.GX12538@two.firstfloor.org>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
 <87lho0pf4l.fsf@tassilo.jf.intel.com>
 <20141029215839.GO2979@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141029215839.GO2979@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

> 
> I suppose from the single-threaded point of view, it could be.  Maybe we

It's not only for single threaded. Consider the "has to wait a long time
for a lock" problem Rik pointed out. With that multiple threads are
always better.

> could look at this a bit differently.  What if we allow processes to
> choose their collapse mechanism on fork?  That way, the system could
> default to using the standard khugepaged mechanism, but we could request
> that processes handle collapses themselves if we want.  Overall, I don't
> think that would add too much overhead to what I've already proposed
> here, and it gives us more flexibility.

We already have too many VM tunables. Better would be to switch
automatically somehow.

I guess you could use some kind of work stealing scheduler, but these
are fairly complicated. Maybe some simpler heuristics can be found.

BTW my thinking has been usually to actually use more khugepageds to 
scan large address spaces faster.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
