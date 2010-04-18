Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 758666B01F3
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 15:35:57 -0400 (EDT)
Date: Sun, 18 Apr 2010 15:35:45 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100418193545.GA28479@infradead.org>
References: <20100414155233.D153.A69D9226@jp.fujitsu.com> <20100414072830.GK2493@dastard> <20100414085132.GJ25756@csn.ul.ie> <20100415013436.GO2493@dastard> <20100415102837.GB10966@csn.ul.ie> <20100416041412.GY2493@dastard> <20100416151403.GM19264@csn.ul.ie> <20100417203239.dda79e88.akpm@linux-foundation.org> <20100418190526.GA1692@infradead.org> <20100418123109.0953b7a5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100418123109.0953b7a5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2010 at 12:31:09PM -0400, Andrew Morton wrote:
> Yeah, but it's all bandaids.  The first thing we should do is work out
> why writeout-off-the-LRU increased so much and fix that.
> 
> Handing writeout off to separate threads might be used to solve the
> stack consumption problem but we shouldn't use it to "solve" the
> excess-writeout-from-page-reclaim problem.

I think both of them are really serious issue.  Exposing the whole
stack and lock problems with direct reclaim are a bit of a positive
side-effect os the writeout tuning messup.  Without it the problems
would still be just as harmfull, just happenening even less often and
thus getting even less attention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
