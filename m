Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 601B06B0113
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 09:17:47 -0400 (EDT)
Message-ID: <4FE9B677.8040409@redhat.com>
Date: Tue, 26 Jun 2012 09:17:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
References: <cover.1340665087.git.aquini@redhat.com> <7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com>
In-Reply-To: <7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>

On 06/25/2012 07:25 PM, Rafael Aquini wrote:
> This patch introduces helper functions that teach compaction and migration bits
> how to cope with pages which are part of a guest memory balloon, in order to
> make them movable by memory compaction procedures.
>
> Signed-off-by: Rafael Aquini<aquini@redhat.com>

The function fill_balloon in drivers/virtio/virtio_balloon.c
should probably add __GFP_MOVABLE to the gfp mask for alloc_pages,
to keep the pageblock where balloon pages are allocated marked
as movable.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
