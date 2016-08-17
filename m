Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5668E6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 10:36:15 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j67so285644895oih.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 07:36:15 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id v128si11901111iod.113.2016.08.17.07.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 07:36:14 -0700 (PDT)
Date: Wed, 17 Aug 2016 09:36:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo
 stats
In-Reply-To: <57B40EA5.9040600@oracle.com>
Message-ID: <alpine.DEB.2.20.1608170935500.12985@east.gentwo.org>
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com> <CAAmzW4On7FWc37fQJOsDQOEOVXqK3ue+uiB0ZOFM9R5e-Jj3WQ@mail.gmail.com> <alpine.DEB.2.20.1608050919410.27772@east.gentwo.org> <20160816030314.GB16913@js1304-P5Q-DELUXE>
 <alpine.DEB.2.20.1608161052080.7887@east.gentwo.org> <57B40EA5.9040600@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aruna.ramakrishna@oracle.com
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 17 Aug 2016, aruna.ramakrishna@oracle.com wrote:

> I'll send out an updated slab counters patch with Joonsoo's suggested fix
> tomorrow (nr_slabs will be unsigned long for SLAB only, and there will be a
> separate definition for SLUB), and once that's in, I'll create a new patch
> that makes nr_slabs common for SLAB and SLUB, and also converts total_objects
> to unsigned long. Maybe it can include some more cleanup too. Does that sound
> acceptable?

Thats fine.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
