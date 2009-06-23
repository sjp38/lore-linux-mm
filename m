Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2AF8F6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 13:40:41 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2D93E82C52A
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 13:58:49 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wIxHG5tGT-aF for <linux-mm@kvack.org>;
	Tue, 23 Jun 2009 13:58:49 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 439BC82C4BF
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 13:58:48 -0400 (EDT)
Date: Tue, 23 Jun 2009 13:41:41 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Performance degradation seen after using one list for hot/cold
 pages.
In-Reply-To: <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0906231338390.11807@gentwo.org>
References: <20626261.51271245670323628.JavaMail.weblogic@epml20> <20090622165236.GE3981@csn.ul.ie> <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, NARAYANAN GOPALAKRISHNAN <narayanan.g@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jun 2009, KAMEZAWA Hiroyuki wrote:

> > Ok, by the looks of things, all the aio_read() requests are due to readahead
> > as opposed to explicit AIO  requests from userspace. In this case, nothing
> > springs to mind that would avoid excessive requests for cold pages.
> >
> > It looks like the simpliest solution is to go with the patch I posted.
> > Does anyone see a better alternative that doesn't branch in rmqueue_bulk()
> > or add back the hot/cold PCP lists?
> >
> No objection.  But 2 questions...

Also no objections here. Readahead makes sense.

> 1. if (likely(coild == 0))
> 	"likely" is necessary ?

Would not think so. Code is sufficiently compact so that the
processor "readahead" will have both branches in cache.

> 2. Why moving pointer "list" rather than following ?
>
> 	if (cold)
> 		list_add(&page->lru, list);
> 	else
> 		list_add_tail(&page->lru, list);

Not sure what your point is here. Can you pickup the patch fix it up and
resubmit? Mel is out for now it seems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
