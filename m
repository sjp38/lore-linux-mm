Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E7D3F6B02BE
	for <linux-mm@kvack.org>; Sun, 20 Oct 2013 14:08:47 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ld10so3825813pab.10
        for <linux-mm@kvack.org>; Sun, 20 Oct 2013 11:08:47 -0700 (PDT)
Received: from psmtp.com ([74.125.245.149])
        by mx.google.com with SMTP id js8si2358019pbc.134.2013.10.20.11.08.46
        for <linux-mm@kvack.org>;
        Sun, 20 Oct 2013 11:08:47 -0700 (PDT)
Date: Sun, 20 Oct 2013 18:08:44 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/5] slab: restrict the number of objects in a slab
In-Reply-To: <CAAmzW4Mzx0FWP6KK7gk88c07RP46WaA9i5DePnzSWt7XP6qQNw@mail.gmail.com>
Message-ID: <00000141d70e0e22-bd66f3af-822a-47dd-bbd9-fe68ad8da2ff-000000@email.amazonses.com>
References: <1381989797-29269-1-git-send-email-iamjoonsoo.kim@lge.com> <1381989797-29269-4-git-send-email-iamjoonsoo.kim@lge.com> <00000141c7cb668b-1e2528ea-ce87-4380-a0dd-e5be9384cd84-000000@email.amazonses.com>
 <CAAmzW4Mzx0FWP6KK7gk88c07RP46WaA9i5DePnzSWt7XP6qQNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Sat, 19 Oct 2013, JoonSoo Kim wrote:

> > Ok so that results in a mininum size object size of 2^(12 - 8) = 2^4 ==
> > 16 bytes on x86. This is not true for order 1 pages (which SLAB also
> > supports) where we need 32 bytes.
>
> According to current slab size calculating logic, slab whose object size is
> less or equal to 16 bytes use only order 0 page. So there is no problem.

Ok then lets add a VM_BUG_ON to detect the situation when someone tries
something different.

> > Problems may arise on PPC or IA64 where the page size may be larger than
> > 64K. With 64K we have a mininum size of 2^(16 - 8) = 256 bytes. For those
> > arches we may need 16 bit sized indexes. Maybe make that compile time
> > determined base on page size? > 64KByte results in 16 bit sized indexes?
>
> Okay. I will try it.

Again compile time. You had runtime in some earlier patches which adds new
branches to key functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
