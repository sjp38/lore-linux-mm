Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 3CA006B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 17:13:34 -0500 (EST)
Date: Tue, 5 Feb 2013 14:13:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] mm: rename confusing function names
Message-Id: <20130205141332.04fcceac.akpm@linux-foundation.org>
In-Reply-To: <20130205192640.GC6481@cmpxchg.org>
References: <51113CE3.5090000@gmail.com>
	<20130205192640.GC6481@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Linux MM <linux-mm@kvack.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, m.szyprowski@samsung.com, linux-kernel@vger.kernel.org

On Tue, 5 Feb 2013 14:26:40 -0500
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Feb 06, 2013 at 01:09:55AM +0800, Zhang Yanfei wrote:
> > Function nr_free_zone_pages, nr_free_buffer_pages and nr_free_pagecache_pages
> > are horribly badly named, they count present_pages - pages_high within zones
> > instead of free pages, so why not rename them to reasonable names, not cofusing
> > people.
> > 
> > patch2 and patch3 are based on patch1. So please apply patch1 first.
> > 
> > Zhang Yanfei (3):
> >   mm: rename nr_free_zone_pages to nr_free_zone_high_pages
> >   mm: rename nr_free_buffer_pages to nr_free_buffer_high_pages
> >   mm: rename nr_free_pagecache_pages to nr_free_pagecache_high_pages
> 
> I don't feel that this is an improvement.
> 
> As you said, the "free" is already misleading, because those pages
> might all be allocated.  "High" makes me think not just of highmem,
> but drug abuse in general.
> 
> nr_available_*_pages?  I don't know, but if we go through with all
> that churn, it had better improve something.

Yes, those names are ghastly.

Here's an idea: accurately document the functions with code comments. 
Once this is done, that documentation may well suggest a good name ;)


While we're there, please note that nr_free_buffer_pages() has a *lot*
of callers.  Generally it's code which is trying to work out what is an
appropriate size for preallocated caching space, lookup tables, etc. 

That's a rather hopeless objective, given memory hotplug, mlock, etc. 
But please do take a look at *why* these callers are calling
nr_free_buffer_pages() and let's ensure that both the implementation
and name are appropriate to their requirements.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
