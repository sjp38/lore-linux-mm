Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 837FC6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 06:28:33 -0400 (EDT)
Received: by pagr17 with SMTP id r17so61128178pag.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:28:33 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id cu9si21560553pad.177.2015.03.16.03.28.31
        for <linux-mm@kvack.org>;
        Mon, 16 Mar 2015 03:28:32 -0700 (PDT)
Message-ID: <5506B04D.1070506@lge.com>
Date: Mon, 16 Mar 2015 19:28:29 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] [RFC] mm/vmalloc: fix possible exhaustion of vmalloc
 space
References: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
In-Reply-To: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Pen <r.peniaev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Eric Dumazet <edumazet@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org



2015-03-13 ?AEA 9:12?! Roman Pen AI(?!)  3/4 ' +-U:
> Hello all.
> 
> Recently I came across high fragmentation of vm_map_ram allocator: vmap_block
> has free space, but still new blocks continue to appear.  Further investigation
> showed that certain mapping/unmapping sequence can exhaust vmalloc space.  On
> small 32bit systems that's not a big problem, cause purging will be called soon
> on a first allocation failure (alloc_vmap_area), but on 64bit machines, e.g.
> x86_64 has 45 bits of vmalloc space, that can be a disaster.

I think the problem you comments is already known so that I wrote comments about it as
"it could consume lots of address space through fragmentation".

Could you tell me about your situation and reason why it should be avoided?


> 
> Fixing this I also did some tweaks in allocation logic of a new vmap block and
> replaced dirty bitmap with min/max dirty range values to make the logic simpler.
> 
> I would like to receive comments on the following three patches.
> 
> Thanks.
> 
> Roman Pen (3):
>    mm/vmalloc: fix possible exhaustion of vmalloc space caused by
>      vm_map_ram allocator
>    mm/vmalloc: occupy newly allocated vmap block just after allocation
>    mm/vmalloc: get rid of dirty bitmap inside vmap_block structure
> 
>   mm/vmalloc.c | 94 ++++++++++++++++++++++++++++++++++--------------------------
>   1 file changed, 54 insertions(+), 40 deletions(-)
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: WANG Chao <chaowang@redhat.com>
> Cc: Fabian Frederick <fabf@skynet.be>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Gioh Kim <gioh.kim@lge.com>
> Cc: Rob Jones <rob.jones@codethink.co.uk>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
