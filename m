Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 983446B0166
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 11:12:58 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so4690097pab.13
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 08:12:58 -0700 (PDT)
Received: from psmtp.com ([74.125.245.204])
        by mx.google.com with SMTP id z1si1155655pbw.99.2013.10.18.08.12.56
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 08:12:57 -0700 (PDT)
Received: by mail-we0-f170.google.com with SMTP id u57so3964111wes.1
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 08:12:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <00000141c7cb668b-1e2528ea-ce87-4380-a0dd-e5be9384cd84-000000@email.amazonses.com>
References: <1381989797-29269-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1381989797-29269-4-git-send-email-iamjoonsoo.kim@lge.com>
	<00000141c7cb668b-1e2528ea-ce87-4380-a0dd-e5be9384cd84-000000@email.amazonses.com>
Date: Sat, 19 Oct 2013 00:12:54 +0900
Message-ID: <CAAmzW4Mzx0FWP6KK7gk88c07RP46WaA9i5DePnzSWt7XP6qQNw@mail.gmail.com>
Subject: Re: [PATCH v2 3/5] slab: restrict the number of objects in a slab
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

2013/10/18 Christoph Lameter <cl@linux.com>:
> n Thu, 17 Oct 2013, Joonsoo Kim wrote:
>
>> To prepare to implement byte sized index for managing the freelist
>> of a slab, we should restrict the number of objects in a slab to be less
>> or equal to 256, since byte only represent 256 different values.
>> Setting the size of object to value equal or more than newly introduced
>> SLAB_MIN_SIZE ensures that the number of objects in a slab is less or
>> equal to 256 for a slab with 1 page.
>
> Ok so that results in a mininum size object size of 2^(12 - 8) = 2^4 ==
> 16 bytes on x86. This is not true for order 1 pages (which SLAB also
> supports) where we need 32 bytes.

According to current slab size calculating logic, slab whose object size is
less or equal to 16 bytes use only order 0 page. So there is no problem.

> Problems may arise on PPC or IA64 where the page size may be larger than
> 64K. With 64K we have a mininum size of 2^(16 - 8) = 256 bytes. For those
> arches we may need 16 bit sized indexes. Maybe make that compile time
> determined base on page size? > 64KByte results in 16 bit sized indexes?

Okay. I will try it.

> Otherwise I like this approach. Simplifies a lot and its very cache
> friendly.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
