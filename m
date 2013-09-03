Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id CE13A6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 10:15:43 -0400 (EDT)
Date: Tue, 3 Sep 2013 14:15:42 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/4] slab: implement byte sized indexes for the freelist
 of a slab
In-Reply-To: <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000140e42dcd61-00e6cf6a-457c-48bd-8bf7-830133923564-000000@email.amazonses.com>
References: <CAAmzW4N1GXbr18Ws9QDKg7ChN5RVcOW9eEv2RxWhaEoHtw=ctw@mail.gmail.com> <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2 Sep 2013, Joonsoo Kim wrote:

> This patchset implements byte sized indexes for the freelist of a slab.
>
> Currently, the freelist of a slab consist of unsigned int sized indexes.
> Most of slabs have less number of objects than 256, so much space is wasted.
> To reduce this overhead, this patchset implements byte sized indexes for
> the freelist of a slab. With it, we can save 3 bytes for each objects.
>
> This introduce one likely branch to functions used for setting/getting
> objects to/from the freelist, but we may get more benefits from
> this change.
>
> Below is some numbers of 'cat /proc/slabinfo' related to my previous posting
> and this patchset.

You  may also want to run some performance tests. The cache footprint
should also be reduced with this patchset and therefore performance should
be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
