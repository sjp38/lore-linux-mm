Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 367686B00EB
	for <linux-mm@kvack.org>; Thu, 17 May 2012 11:49:20 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4012445pbb.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 08:49:19 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 0/4] slub: refactoring some code in slub
Date: Fri, 18 May 2012 00:47:44 +0900
Message-Id: <1337269668-4619-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

These patches are for refactoring some code in slub.

Two patches were submitted 1 weeks ago, but doesn't receive ack or nack
from MAINTAINER for slub. So I re-send these.

https://lkml.org/lkml/2012/5/10/273
https://lkml.org/lkml/2012/5/10/275

Among others, one about page-flag is very simple change.
Last one is main target of this patch set.

It is dependent on 'slub: change cmpxchg_double_slab in 
unfreeze_partials to __cmpxchg_double_slab', so I send these at one time.

Joonsoo Kim (4):
  slub: change cmpxchg_double_slab in get_freelist() to
    __cmpxchg_double_slab
  slub: change cmpxchg_double_slab in unfreeze_partials to
    __cmpxchg_double_slab
  slub: use __SetPageSlab function to set PG_slab flag
  slub: refactoring unfreeze_partials()

 mm/slub.c |   54 +++++++++++++++++-------------------------------------
 1 file changed, 17 insertions(+), 37 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
