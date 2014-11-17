Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF286B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 16:33:57 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id hz1so11906053pad.13
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 13:33:57 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id gg1si36045566pbc.237.2014.11.17.13.33.55
        for <linux-mm@kvack.org>;
        Mon, 17 Nov 2014 13:33:56 -0800 (PST)
Date: Mon, 17 Nov 2014 15:34:15 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
Message-ID: <20141117213415.GU21147@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
 <87lho0pf4l.fsf@tassilo.jf.intel.com>
 <544F9302.4010001@redhat.com>
 <544FB8A8.1090402@redhat.com>
 <5453F0A4.4090708@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5453F0A4.4090708@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On Fri, Oct 31, 2014 at 09:27:16PM +0100, Vlastimil Babka wrote:
> What could help would be to cache one or few free huge pages per
> zone with cache
> re-fill done asynchronously, e.g. via work queues. The cache could
> benefit fault-THP
> allocations as well. And adding some logic that if nobody uses the
> cached pages and
> memory is low, then free them. And importantly, if it's not possible
> to allocate huge
> pages for the cache, then prevent scanning for collapse candidates
> as there's no point.
> (well this is probably more complex if some nodes can allocate huge
> pages and others
> not).

I think this would be a pretty cool addition, even separately from this
effort.  If we keep a page cached on each NUMA node, then we could,
theoretically, really speed up the khugepaged scans (even if we don't
move those scans to task_work), and regular THP faults.  I'll add it to
my ever-growing wish list :)

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
