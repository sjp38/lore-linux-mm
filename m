Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id DED0B6B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 14:52:54 -0400 (EDT)
Date: Mon, 3 Jun 2013 20:52:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 10/10] mm: workingset: keep shadow entries in check
Message-ID: <20130603185228.GG8923@twins.programming.kicks-ass.net>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
 <1369937046-27666-11-git-send-email-hannes@cmpxchg.org>
 <20130603082533.GH5910@twins.programming.kicks-ass.net>
 <20130603152032.GF15576@cmpxchg.org>
 <20130603171558.GE8923@twins.programming.kicks-ass.net>
 <20130603181202.GI15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603181202.GI15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Mon, Jun 03, 2013 at 02:12:02PM -0400, Johannes Weiner wrote:
> > But given that, sure maybe 1 memory size is a bit strict, but surely we
> > can put a limit on things at about 2 memory sizes?
> 
> That's what this 10/10 patch does (prune everything older than 2 *
> global_dirtyable_memory()), so I think we're talking past each other.
> 
> Maybe the wording of the changelog was confusing?  The paragraph you
> quoted above explains the problem resulting from 9/10 but which this
> patch 10/10 fixes.

Could be I just didn't read very well -- I pretty much raced through the
patches trying to get a general overview and see if I could spot
something weird.

I'll try again and let you know :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
