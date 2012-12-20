Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 7A39E6B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 06:14:10 -0500 (EST)
Date: Thu, 20 Dec 2012 11:14:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] sched: numa: ksm: fix oops in task_numa_placment()
Message-ID: <20121220111405.GE10819@suse.de>
References: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 19, 2012 at 05:42:16PM -0800, Hugh Dickins wrote:
> task_numa_placement() oopsed on NULL p->mm when task_numa_fault()
> got called in the handling of break_ksm() for ksmd.  That might be a
> peculiar case, which perhaps KSM could takes steps to avoid? but it's
> more robust if task_numa_placement() allows for such a possibility.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
