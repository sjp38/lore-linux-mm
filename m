Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 6CED36B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 13:46:36 -0400 (EDT)
Date: Fri, 29 Jun 2012 14:46:25 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2 0/4] make balloon pages movable by compaction
Message-ID: <20120629174624.GC1774@t510.redhat.com>
References: <cover.1340916058.git.aquini@redhat.com>
 <87r4syzqkn.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r4syzqkn.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Fri, Jun 29, 2012 at 02:01:52PM +0930, Rusty Russell wrote:
> On Thu, 28 Jun 2012 18:49:38 -0300, Rafael Aquini <aquini@redhat.com> wrote:
> > This patchset follows the main idea discussed at 2012 LSFMMS section:
> > "Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/
> > 
> > to introduce the required changes to the virtio_balloon driver, as well as
> > changes to the core compaction & migration bits, in order to allow
> > memory balloon pages become movable within a guest.
> > 
> > Rafael Aquini (4):
> >   mm: introduce compaction and migration for virtio ballooned pages
> >   virtio_balloon: handle concurrent accesses to virtio_balloon struct
> >     elements
> >   virtio_balloon: introduce migration primitives to balloon pages
> >   mm: add vm event counters for balloon pages compaction
> > 
> >  drivers/virtio/virtio_balloon.c |  142 +++++++++++++++++++++++++++++++++++----
> >  include/linux/mm.h              |   16 +++++
> >  include/linux/virtio_balloon.h  |    6 ++
> >  include/linux/vm_event_item.h   |    2 +
> >  mm/compaction.c                 |  111 ++++++++++++++++++++++++------
> >  mm/migrate.c                    |   32 ++++++++-
> >  mm/vmstat.c                     |    4 ++
> >  7 files changed, 280 insertions(+), 33 deletions(-)
> > 
> > 
> > V2: address Mel Gorman's review comments
> 
> If Mel is happy, I am happy.  Seems sensible that the virtio_baloon
> changes go in at the same time as the mm changes, so:
> 
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks Rusty!

I'll be respinning a v3 to address some extra suggestions Mel did, so if you
have any concern that you'd like me to address, do not hesitate on letting me
know! 

Cheers!
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
