Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB888828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:24:45 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 4so32464392oih.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:24:45 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [96.114.154.171])
        by mx.google.com with ESMTPS id 101si18553545iom.252.2016.08.05.07.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 07:22:57 -0700 (PDT)
Date: Fri, 5 Aug 2016 09:21:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo
 stats
In-Reply-To: <CAAmzW4On7FWc37fQJOsDQOEOVXqK3ue+uiB0ZOFM9R5e-Jj3WQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1608050919410.27772@east.gentwo.org>
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com> <CAAmzW4On7FWc37fQJOsDQOEOVXqK3ue+uiB0ZOFM9R5e-Jj3WQ@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 5 Aug 2016, Joonsoo Kim wrote:

> If above my comments are fixed, all counting would be done with
> holding a lock. So, atomic definition isn't needed for the SLAB.

Ditto for slub. struct kmem_cache_node is alrady defined in mm/slab.h.
Thus it is a common definition already and can be used by both.

Making nr_slabs and total_objects unsigned long would be great.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
