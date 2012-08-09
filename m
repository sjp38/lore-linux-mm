Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 534F46B0044
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 21:39:44 -0400 (EDT)
Message-ID: <502314C3.2020509@redhat.com>
Date: Wed, 08 Aug 2012 21:39:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 2/3] virtio_balloon: introduce migration primitives
 to balloon pages
References: <cover.1344463786.git.aquini@redhat.com> <5f4b30060e252e557882595984a8225ba6e0c9f2.1344463786.git.aquini@redhat.com>
In-Reply-To: <5f4b30060e252e557882595984a8225ba6e0c9f2.1344463786.git.aquini@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On 08/08/2012 06:53 PM, Rafael Aquini wrote:
> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
>
> Besides making balloon pages movable at allocation time and introducing
> the necessary primitives to perform balloon page migration/compaction,
> this patch also introduces the following locking scheme to provide the
> proper synchronization and protection for struct virtio_balloon elements
> against concurrent accesses due to parallel operations introduced by
> memory compaction / page migration.
>   - balloon_lock (mutex) : synchronizes the access demand to elements of
> 			  struct virtio_balloon and its queue operations;
>   - pages_lock (spinlock): special protection to balloon pages list against
> 			  concurrent list handling operations;
>
> Signed-off-by: Rafael Aquini<aquini@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
