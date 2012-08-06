Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id A6B1F6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 15:24:52 -0400 (EDT)
Date: Mon, 6 Aug 2012 16:24:18 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v5 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120806192418.GB3968@t510.redhat.com>
References: <cover.1344259054.git.aquini@redhat.com>
 <212b5297df32cb4e3f60d5b76a8cb0629d328a4e.1344259054.git.aquini@redhat.com>
 <50200F1F.7060605@redhat.com>
 <20120806190053.GA3968@t510.redhat.com>
 <502015C9.2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502015C9.2@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Mon, Aug 06, 2012 at 03:06:49PM -0400, Rik van Riel wrote:
> 
> Just a plain rename would work.
>
Ok, I will rename it.
 
> >+static inline bool is_balloon_page(struct page *page)
> >+{
> >+	return (page->mapping && page->mapping == balloon_mapping);
> >+}
> 
> As an aside, since you are only comparing page->mapping and
> not dereferencing it, it can be simplified to just:
> 
> 	return (page->mapping == balloon_mapping);
> 
We really need both comparisons to avoid potential NULL pointer dereferences at
__isolate_balloon_page() & __putback_balloon_page() while running at bare metal
with no balloon driver loaded, since balloon_mapping itself is a pointer which
each balloon driver can set to its own structure. 

Thanks, Rik, for taking the time to look at this patch and provide (always)
valuable feedback.

I'll shortly respin a v6 with your suggestions.

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
