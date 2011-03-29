Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 543BC8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:39:01 -0400 (EDT)
Date: Wed, 30 Mar 2011 00:38:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110329223858.GO12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
 <20110329190520.GJ12265@random.random>
 <4D924D8C.8060201@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D924D8C.8060201@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Tue, Mar 29, 2011 at 05:22:20PM -0400, Rik van Riel wrote:
> I believe that problem is complex enough to warrant a 30
> minute discussion.  Even if we do not come up with solutions,
> it would be a good start if we could all agree on the problem.
> 
> Things this complex often end up getting shot down later, not
> because people do not agree on the solution, but because people
> do not agree on the PROBLEM (and the patches in question only
> solve a subset of the problem).
> 
> I would be willing to lead the NUMA scheduling and memory
> allocation discussion.

Well, for now I added it to schedule.

The problem I think exists as without bindings and NUMA hinting, the
current automatic behavior deviates significantly from the tuned-NUMA
binding performance as also shown by the migrate-on-fault patches.

Now THP pages can't even be migrated before being splitted, and
migrating 2M on fault isn't optimal even after we teach migrate how to
migrate 2M pages without splitting [a separate issue]. Migrate on
fault to me looks a great improvement but it doesn't look the most
optimal design we can have as the page fault can be avoided with a
background migration from kernel thread, without requiring page faults.

Hugh if you think of some other topic being more urgent feel free to
update. One other topic that comes to mind right now that could be
good candidate for the floating slot would be Hugh's OOM topic. I
think it'd be nice to somehow squeeze that into the schedule too if
Hugh has interest to lead it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
