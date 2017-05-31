Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 542876B02F3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 10:09:06 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l78so14375723iod.4
        for <linux-mm@kvack.org>; Wed, 31 May 2017 07:09:06 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id o197si14969122ioo.21.2017.05.31.07.09.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 07:09:05 -0700 (PDT)
Date: Wed, 31 May 2017 09:09:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <87h9014j7t.fsf@concordia.ellerman.id.au>
Message-ID: <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Hugh Dickins <hughd@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Wed, 31 May 2017, Michael Ellerman wrote:

> > SLUB: Unable to allocate memory on node -1, gfp=0x14000c0(GFP_KERNEL)
> >   cache: pgtable-2^12, object size: 32768, buffer size: 65536, default order: 4, min order: 4
> >   pgtable-2^12 debugging increased min order, use slub_debug=O to disable.

Ahh. Ok debugging increased the object size to an order 4. This should be
order 3 without debugging.

> > I did try booting with slub_debug=O as the message suggested, but that
> > made no difference: it still hoped for but failed on order:4 allocations.

I am curious as to what is going on there. Do you have the output from
these failed allocations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
