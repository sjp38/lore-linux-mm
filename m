Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 4A6036B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 05:32:05 -0400 (EDT)
Date: Mon, 26 Mar 2012 10:32:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Re: kswapd stuck using 100% CPU
Message-ID: <20120326093201.GL1007@csn.ul.ie>
References: <20120324130353.48f2e4c8@kryten>
 <20120324102621.353114da@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120324102621.353114da@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Anton Blanchard <anton@samba.org>, aarcange@redhat.com, akpm@linux-foundation.org, hughd@google.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sat, Mar 24, 2012 at 10:26:21AM -0400, Rik van Riel wrote:
> 
> Only test compaction_suitable if the kernel is built with CONFIG_COMPACTION,
> otherwise the stub compaction_suitable function will always return
> COMPACT_SKIPPED and send kswapd into an infinite loop.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Reported-by: Anton Blanchard <anton@samba.org>
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
