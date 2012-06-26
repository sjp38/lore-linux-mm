Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 264A36B0112
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 09:20:59 -0400 (EDT)
Date: Tue, 26 Jun 2012 14:20:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120626132055.GI8103@csn.ul.ie>
References: <cover.1340665087.git.aquini@redhat.com>
 <7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com>
 <4FE9B677.8040409@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FE9B677.8040409@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org

On Tue, Jun 26, 2012 at 09:17:43AM -0400, Rik van Riel wrote:
> On 06/25/2012 07:25 PM, Rafael Aquini wrote:
> >This patch introduces helper functions that teach compaction and migration bits
> >how to cope with pages which are part of a guest memory balloon, in order to
> >make them movable by memory compaction procedures.
> >
> >Signed-off-by: Rafael Aquini<aquini@redhat.com>
> 
> The function fill_balloon in drivers/virtio/virtio_balloon.c
> should probably add __GFP_MOVABLE to the gfp mask for alloc_pages,
> to keep the pageblock where balloon pages are allocated marked
> as movable.
> 

You're right, but patch 3 is already doing that at the same time the
migration primitives are introduced. It does mean the full series has to
be applied to do anything but I think it's bisect safe.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
