Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1C9368D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 17:22:24 -0400 (EDT)
Message-ID: <4D924D8C.8060201@redhat.com>
Date: Tue, 29 Mar 2011 17:22:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
References: <1301373398.2590.20.camel@mulgrave.site> <4D91FC2D.4090602@redhat.com> <20110329190520.GJ12265@random.random>
In-Reply-To: <20110329190520.GJ12265@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On 03/29/2011 03:05 PM, Andrea Arcangeli wrote:

> Should the latency issues be discussed in that track?

Sounds good.  I don't think we'll spend more than 5-10 minutes
on the latency thing, probably less than that.

> The MM schedule has still a free slot 14-14:30 on Monday, I wonder if
> there's interest on a "NUMA automatic migration and scheduling
> awareness" topic or if it's still too vapourware for a real topic and
> we should keep it for offtrack discussions,

I believe that problem is complex enough to warrant a 30
minute discussion.  Even if we do not come up with solutions,
it would be a good start if we could all agree on the problem.

Things this complex often end up getting shot down later, not
because people do not agree on the solution, but because people
do not agree on the PROBLEM (and the patches in question only
solve a subset of the problem).

I would be willing to lead the NUMA scheduling and memory
allocation discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
