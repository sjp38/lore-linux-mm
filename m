Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DA0106B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 16:35:17 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so1622111pad.19
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 13:35:17 -0700 (PDT)
Message-ID: <525EF85A.6050302@intel.com>
Date: Wed, 16 Oct 2013 13:34:34 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
References: <1381800678-16515-1-git-send-email-ccross@android.com>	<1381800678-16515-2-git-send-email-ccross@android.com>	<20131016003347.GC13007@bbox> <CAMbhsRTe9Vwa-zrebuKeJKpy-AhsSeiFD5nKU_-sNd2G2D-+og@mail.gmail.com>
In-Reply-To: <CAMbhsRTe9Vwa-zrebuKeJKpy-AhsSeiFD5nKU_-sNd2G2D-+og@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>, Minchan Kim <minchan@kernel.org>
Cc: lkml <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Glauber <jan.glauber@gmail.com>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Kees Cook <keescook@chromium.org>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, open@kvack.org, list@kvack.org, DOCUMENTATION <linux-doc@vger.kernel.org>open@kvack.orglist@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>

On 10/16/2013 01:00 PM, Colin Cross wrote:
>> > I guess this feature would be used with allocators tightly
>> > so my concern of kernel approach like this that it needs mmap_sem
>> > write-side lock to split/merge vmas which is really thing
>> > allocators(ex, tcmalloc, jemalloc) want to avoid for performance win
>> > that allocators have lots of complicated logic to avoid munmap which
>> > needs mmap_sem write-side lock but this feature would make it invalid.
> My expected use case is that the allocator will mmap a new large chunk
> of anonymous memory, and then immediately name it, resulting in taking
> the mmap_sem twice in a row. 

I guess the prctl (or a new one) _could_ just set a kernel-internal
variable (per-thread?) that says "point any future anonymous areas at
this name".  That way, you at least have the _possibility_ of not having
to do it for _every_ mmap().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
