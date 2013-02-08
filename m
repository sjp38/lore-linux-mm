Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 639B76B000A
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 08:34:44 -0500 (EST)
Date: Fri, 8 Feb 2013 07:34:41 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 0/3] mm: rename confusing function names
Message-ID: <20130208133441.GH3460@sgi.com>
References: <51113CE3.5090000@gmail.com>
 <20130205192640.GC6481@cmpxchg.org>
 <20130205141332.04fcceac.akpm@linux-foundation.org>
 <5111AC7D.9070505@cn.fujitsu.com>
 <20130205172057.3be4dbd4.akpm@linux-foundation.org>
 <5111B318.9020204@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5111B318.9020204@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Linux MM <linux-mm@kvack.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, m.szyprowski@samsung.com, linux-kernel@vger.kernel.org

> > static unsigned int nr_free_zone_pages(int offset)
> > {
> > 	...
> > 	unsigned int sum = 0;
> > 	...
> > 	return sum;
> > }
> > 
> > How long will it be until these things start exploding from
> > sums-of-zones which exceed 16TB?  
> > 
> 
> You mean overflow? Hmm.. it might happens. Change the sum to
> unsigned long is ok?

We are in the process right now of building a 32TB machine.  Let me make
a note about this right away.  Thankfully, the memory will be spread
over 256 zones so it should not impact us right away.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
