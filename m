Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 616946B0099
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 10:02:27 -0500 (EST)
Date: Fri, 19 Feb 2010 09:01:44 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 03/12] mm: Share the anon_vma ref counts between KSM and
 page migration
In-Reply-To: <20100219140500.GG30258@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1002190857230.7486@router.home>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-4-git-send-email-mel@csn.ul.ie> <20100219091859.195d922c.kamezawa.hiroyu@jp.fujitsu.com> <20100219140500.GG30258@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Feb 2010, Mel Gorman wrote:

> > Nitpick:
> > I think this refcnt has something different characteristics than other
> > usual refcnts. Even when refcnt goes down to 0, anon_vma will not be freed.
> > So, I think some kind of name as temporal_reference_count is better than
> > simple "refcnt". Then, it will be clearer what this refcnt is for.
> >
>
> When I read this in a few years, I'll have no idea what "temporal" is
> referring to. The holder of this account is by a process that does not
> necessarily own the page or its mappings but "remote" has special
> meaning as well. "external_count" ?

We could think about getting rid of RCU for anon_vmas and use the refcount
for everything. Would make the handling consistent with other users but
will have performance implications.

Hugh what do you say about this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
