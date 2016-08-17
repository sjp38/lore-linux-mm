Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F86C6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 03:13:51 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m130so276654112ioa.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 00:13:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 193si10894148itq.42.2016.08.17.00.13.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 00:13:50 -0700 (PDT)
From: aruna.ramakrishna@oracle.com
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo
 stats
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
 <CAAmzW4On7FWc37fQJOsDQOEOVXqK3ue+uiB0ZOFM9R5e-Jj3WQ@mail.gmail.com>
 <alpine.DEB.2.20.1608050919410.27772@east.gentwo.org>
 <20160816030314.GB16913@js1304-P5Q-DELUXE>
 <alpine.DEB.2.20.1608161052080.7887@east.gentwo.org>
Message-ID: <57B40EA5.9040600@oracle.com>
Date: Wed, 17 Aug 2016 00:13:41 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1608161052080.7887@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>


On 08/16/2016 08:52 AM, Christoph Lameter wrote:
>
> On Tue, 16 Aug 2016, Joonsoo Kim wrote:
>
>> In SLUB, nr_slabs is manipulated without holding a lock so atomic
>> operation should be used.
>
> It could be moved under the node lock.
>

Christoph, Joonsoo,

I agree that nr_slabs could be common between SLAB and SLUB, but I think 
that should be a separate patch, since converting nr_slabs to unsigned 
long for SLUB will cause quite a bit of change in mm/slub.c that is not 
related to adding counters to SLAB.

I'll send out an updated slab counters patch with Joonsoo's suggested 
fix tomorrow (nr_slabs will be unsigned long for SLAB only, and there 
will be a separate definition for SLUB), and once that's in, I'll create 
a new patch that makes nr_slabs common for SLAB and SLUB, and also 
converts total_objects to unsigned long. Maybe it can include some more 
cleanup too. Does that sound acceptable?

Thanks,
Aruna

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
