Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id C1FFF6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 23:12:36 -0400 (EDT)
Message-ID: <5036F111.4040607@redhat.com>
Date: Thu, 23 Aug 2012 23:12:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon pages
 mobility
References: <20120822011930.GA23753@t510.redhat.com> <20120822093317.GC10680@redhat.com> <20120823021903.GA23660@x61.redhat.com> <20120823100107.GA17409@redhat.com> <20120823121338.GA3062@t510.redhat.com> <20120823123432.GA25659@redhat.com> <20120823130606.GB3746@t510.redhat.com> <20120823135328.GB25709@redhat.com> <20120823162504.GA1522@redhat.com> <20120823172844.GC10777@t510.redhat.com> <20120823233616.GB2775@redhat.com>
In-Reply-To: <20120823233616.GB2775@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On 08/23/2012 07:36 PM, Michael S. Tsirkin wrote:

> --->
>
> virtio-balloon: replace page->lru list with page->private.
>
> The point is to free up page->lru for use by compaction.
> Warning: completely untested, will provide tested version
> if we agree on this direction.

A singly linked list is not going to work for page migration,
which needs to get pages that might be in the middle of the
balloon list.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
