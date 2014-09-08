Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 58C766B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 12:10:26 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id r10so21231944pdi.15
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 09:10:26 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id xg2si18788027pab.67.2014.09.08.09.10.25
        for <linux-mm@kvack.org>;
        Mon, 08 Sep 2014 09:10:25 -0700 (PDT)
Date: Mon, 8 Sep 2014 11:10:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: implement kmalloc guard
In-Reply-To: <alpine.LRH.2.02.1409081041160.29432@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.11.1409081108190.20388@gentwo.org>
References: <alpine.LRH.2.02.1409051833510.9790@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.11.1409080932490.20388@gentwo.org> <alpine.LRH.2.02.1409081041160.29432@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, Milan Broz <gmazyland@gmail.com>, kkolasa@winsoft.pl, dm-devel@redhat.com

On Mon, 8 Sep 2014, Mikulas Patocka wrote:

> I don't know what you mean. If someone allocates 10000 objects with sizes
> from 1 to 10000, you can't have 10000 slab caches - you can't have a slab
> cache for each used size. Also - you can't create a slab cache in
> interrupt context.

Oh you can create them up front on bootup. And I think only the small
sizes matter. Allocations >=8K are pushed to the page allocator anyways.

> > We already have a redzone structure to check for writes over the end of
> > the object. Lets use that.
>
> So, change all three slab subsystems to use that.

SLOB has no debugging features and I think that was intentional. We are
trying to unify the debug checks etc. Some work on that would be
appreciated. I think the kmalloc creation is already in slab_common.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
