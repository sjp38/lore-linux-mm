Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 4F9576B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 02:38:30 -0400 (EDT)
Date: Thu, 20 Jun 2013 02:38:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/3] mm, vmalloc: cleanup for vmap block
Message-ID: <20130620063817.GA1079@cmpxchg.org>
References: <51B1AD2F.4030702@cn.fujitsu.com>
 <006801ce6577$a50317c0$ef094740$@min@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <006801ce6577$a50317c0$ef094740$@min@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chanho Min <chanho.min@lge.com>
Cc: 'Zhang Yanfei' <zhangyanfei@cn.fujitsu.com>, 'Andrew Morton' <akpm@linux-foundation.org>, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, 'Linux MM' <linux-mm@kvack.org>, 'Mel Gorman' <mgorman@suse.de>

On Mon, Jun 10, 2013 at 10:12:57AM +0900, Chanho Min wrote:
> > This patchset is a cleanup for vmap block. And similar/same
> > patches has been submitted before:
> > - Johannes Weiner's patch: https://lkml.org/lkml/2011/4/14/619
> > - Chanho Min's patch: https://lkml.org/lkml/2013/2/6/810
> 
> This is exactly the same patch as mine. The previous two patches are
> should be concluded.

Ping.  This code is identical, it should credit Chanho as the original
author.  And I agree that the patches should be folded into one patch.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
