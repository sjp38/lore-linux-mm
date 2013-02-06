Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D10A06B002F
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 20:20:58 -0500 (EST)
Date: Tue, 5 Feb 2013 17:20:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] mm: rename confusing function names
Message-Id: <20130205172057.3be4dbd4.akpm@linux-foundation.org>
In-Reply-To: <5111AC7D.9070505@cn.fujitsu.com>
References: <51113CE3.5090000@gmail.com>
	<20130205192640.GC6481@cmpxchg.org>
	<20130205141332.04fcceac.akpm@linux-foundation.org>
	<5111AC7D.9070505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Linux MM <linux-mm@kvack.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, m.szyprowski@samsung.com, linux-kernel@vger.kernel.org

On Wed, 06 Feb 2013 09:06:05 +0800
Zhang Yanfei <zhangyanfei@cn.fujitsu.com> wrote:

> So could I rename the functions to the names like
> nr_available_buffer_high_pages
> And accurately document them with code comments just as you suggested.

gee.  "available" implies "available for you to allocate".  It has the
same problem as "free".

And "buffer" shouldn't be there - that's a reflection of the fact
that buffer_head payloads are not allocated from highmem.  An archaic
irrelevant thing.

Seriously, first let's write down the descriptions of what these
functions *do*.  Then choose nice names which abbreviate that.



hm,

static unsigned int nr_free_zone_pages(int offset)
{
	...
	unsigned int sum = 0;
	...
	return sum;
}

How long will it be until these things start exploding from
sums-of-zones which exceed 16TB?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
