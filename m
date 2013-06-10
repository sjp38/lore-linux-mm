From: "Chanho Min" <chanho.min@lge.com>
Subject: RE: [PATCH 0/3] mm, vmalloc: cleanup for vmap block
Date: Mon, 10 Jun 2013 10:12:57 +0900
Message-ID: <46344.8857692585$1370826793@news.gmane.org>
References: <51B1AD2F.4030702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UlqfO-0003ko-L5
	for glkm-linux-mm-2@m.gmane.org; Mon, 10 Jun 2013 03:13:02 +0200
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 0BCCF6B0031
	for <linux-mm@kvack.org>; Sun,  9 Jun 2013 21:12:59 -0400 (EDT)
In-Reply-To: <51B1AD2F.4030702@cn.fujitsu.com>
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Zhang Yanfei' <zhangyanfei@cn.fujitsu.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, 'Linux MM' <linux-mm@kvack.org>, 'Mel Gorman' <mgorman@suse.de>

> This patchset is a cleanup for vmap block. And similar/same
> patches has been submitted before:
> - Johannes Weiner's patch: https://lkml.org/lkml/2011/4/14/619
> - Chanho Min's patch: https://lkml.org/lkml/2013/2/6/810

This is exactly the same patch as mine. The previous two patches are
should be concluded.

> In Johannes's thread, Mel suggested to figure out if this
> bitmap was not supposed to be doing something useful and depending
> on that implement recycling of partially used vmap blocks.
> 
> Anyway, just as Johannes said, we shouldn't leave these dead/unused
> code as is, because it really is a waste of time for cpus and readers
> of the code. And this cleanup doesn't prevent anyone from improving
> the algorithm later on.

I agree. This unnecessarily bitmap operation can cause significant
overhead as https://lkml.org/lkml/2013/2/7/705.

Thanks
Chanho Min

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
