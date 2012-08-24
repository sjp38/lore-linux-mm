Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B40CE6B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 04:02:36 -0400 (EDT)
Date: Fri, 24 Aug 2012 11:03:27 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120824080327.GA7830@redhat.com>
References: <20120823021903.GA23660@x61.redhat.com>
 <20120823100107.GA17409@redhat.com>
 <20120823121338.GA3062@t510.redhat.com>
 <20120823123432.GA25659@redhat.com>
 <20120823130606.GB3746@t510.redhat.com>
 <20120823135328.GB25709@redhat.com>
 <20120823162504.GA1522@redhat.com>
 <20120823172844.GC10777@t510.redhat.com>
 <20120823233616.GB2775@redhat.com>
 <5036F111.4040607@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5036F111.4040607@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Thu, Aug 23, 2012 at 11:12:17PM -0400, Rik van Riel wrote:
> On 08/23/2012 07:36 PM, Michael S. Tsirkin wrote:
> 
> >--->
> >
> >virtio-balloon: replace page->lru list with page->private.
> >
> >The point is to free up page->lru for use by compaction.
> >Warning: completely untested, will provide tested version
> >if we agree on this direction.
> 
> A singly linked list is not going to work for page migration,
> which needs to get pages that might be in the middle of the
> balloon list.

For virtballoon_migratepage? Hmm I think you are right. I'll
need to think it over but if we can think of no other way
to avoid ther need to handle isolation in virtio,
we'll just have to use the original plan and add
balloon core to mm.

> -- 
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
