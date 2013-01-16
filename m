Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 01A3A6B0062
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 03:44:57 -0500 (EST)
Date: Wed, 16 Jan 2013 17:45:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] slub: correct bootstrap() for kmem_cache,
 kmem_cache_node
Message-ID: <20130116084459.GB13446@lge.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1358234402-2615-2-git-send-email-iamjoonsoo.kim@lge.com>
 <0000013c3eda78d8-da8c775c-d7c0-4a88-bacf-0b5160b5c668-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013c3eda78d8-da8c775c-d7c0-4a88-bacf-0b5160b5c668-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 15, 2013 at 03:36:10PM +0000, Christoph Lameter wrote:
> On Tue, 15 Jan 2013, Joonsoo Kim wrote:
> 
> > These didn't make any error previously, because we normally don't free
> > objects which comes from kmem_cache's first slab and kmem_cache_node's.
> 
> And these slabs are on the partial list because the objects are typically
> relatively small compared to page size. Do you have a system with a very
> large kmem_cache size?

These slabs are not on the partial list, but on the cpu_slab of boot cpu.
Reason for this is described in changelog.
Because these slabs are not on partial list, we need to
check kmem_cache_cpu's cpu slab. This patch implement it.

> > Problem will be solved if we consider a cpu slab in bootstrap().
> > This patch implement it.
> 
> At boot time only one processor is up so you do not need the loop over all
> processors.

Okay! I will fix and submit v2, soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
