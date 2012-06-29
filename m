Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 56DC16B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 00:36:19 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 0/4] make balloon pages movable by compaction
In-Reply-To: <cover.1340916058.git.aquini@redhat.com>
References: <cover.1340916058.git.aquini@redhat.com>
Date: Fri, 29 Jun 2012 14:01:52 +0930
Message-ID: <87r4syzqkn.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, 28 Jun 2012 18:49:38 -0300, Rafael Aquini <aquini@redhat.com> wrote:
> This patchset follows the main idea discussed at 2012 LSFMMS section:
> "Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/
> 
> to introduce the required changes to the virtio_balloon driver, as well as
> changes to the core compaction & migration bits, in order to allow
> memory balloon pages become movable within a guest.
> 
> Rafael Aquini (4):
>   mm: introduce compaction and migration for virtio ballooned pages
>   virtio_balloon: handle concurrent accesses to virtio_balloon struct
>     elements
>   virtio_balloon: introduce migration primitives to balloon pages
>   mm: add vm event counters for balloon pages compaction
> 
>  drivers/virtio/virtio_balloon.c |  142 +++++++++++++++++++++++++++++++++++----
>  include/linux/mm.h              |   16 +++++
>  include/linux/virtio_balloon.h  |    6 ++
>  include/linux/vm_event_item.h   |    2 +
>  mm/compaction.c                 |  111 ++++++++++++++++++++++++------
>  mm/migrate.c                    |   32 ++++++++-
>  mm/vmstat.c                     |    4 ++
>  7 files changed, 280 insertions(+), 33 deletions(-)
> 
> 
> V2: address Mel Gorman's review comments

If Mel is happy, I am happy.  Seems sensible that the virtio_baloon
changes go in at the same time as the mm changes, so:

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
