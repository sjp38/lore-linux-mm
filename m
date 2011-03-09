Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 58AF38D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 21:47:36 -0500 (EST)
Date: Tue, 8 Mar 2011 21:47:08 -0500
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH 0/6] enable writing to /proc/pid/mem
Message-ID: <20110309024708.GA4941@fibrous.localdomain>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca> <20110309013017.GY22723@ZenIV.linux.org.uk> <20110309021524.GA4838@fibrous.localdomain> <20110309023303.GZ22723@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110309023303.GZ22723@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Wed, Mar 09, 2011 at 02:33:04AM +0000, Al Viro wrote:
> On Tue, Mar 08, 2011 at 09:15:25PM -0500, Stephen Wilson wrote:
> 
> > I think we could also remove the intermediate copy in both mem_read() and
> > mem_write() as well, but I think such optimizations could be left for
> > follow on patches.
> 
> How?  We do copy_.._user() in there; it can trigger page faults and
> that's not something you want while holding mmap_sem on some mm.

Ah, OK.   I did not think thru that subtlety.  Was merely mentioning
"things we might do afterwords" as opposed to a genuine proposal.

> Looks like a deadlock country...  So we can't do that from inside
> access_process_vm() or its analogs, which means buffering in caller.

Thanks for the feed back -- I am certainly (relatively speaking) new to
the code so your insights are most valuable.

Thanks again!


-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
