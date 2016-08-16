Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 811A26B0253
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 11:52:37 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q83so81669632iod.0
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 08:52:37 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id p137si1312805itb.29.2016.08.16.08.52.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Aug 2016 08:52:36 -0700 (PDT)
Date: Tue, 16 Aug 2016 10:52:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo
 stats
In-Reply-To: <20160816030314.GB16913@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.20.1608161052080.7887@east.gentwo.org>
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com> <CAAmzW4On7FWc37fQJOsDQOEOVXqK3ue+uiB0ZOFM9R5e-Jj3WQ@mail.gmail.com> <alpine.DEB.2.20.1608050919410.27772@east.gentwo.org> <20160816030314.GB16913@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>


On Tue, 16 Aug 2016, Joonsoo Kim wrote:

> In SLUB, nr_slabs is manipulated without holding a lock so atomic
> operation should be used.

It could be moved under the node lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
