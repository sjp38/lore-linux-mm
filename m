Subject: Re: [PATCH]: VM 8/8 shrink_list(): set PG_reclaimed
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <16994.40728.397980.431164@gargle.gargle.HOWL>
References: <16994.40728.397980.431164@gargle.gargle.HOWL>
Content-Type: text/plain
Date: Mon, 18 Apr 2005 11:13:56 +1000
Message-Id: <1113786837.5124.7.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2005-04-17 at 21:38 +0400, Nikita Danilov wrote:
> set PG_reclaimed bit on pages that are under writeback when shrink_list()
> looks at them: these pages are at end of the inactive list, and it only makes
> sense to reclaim them as soon as possible when writeout finishes.
> 

I agree it makes sense, but this is racy I think. It will leave
PG_reclaim set in some cases and hit bad_page. The trivial fix is
to remove the PG_reclaim check from bad_page. It looks a bit more
tricky to do it "nicely".


-- 
SUSE Labs, Novell Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
