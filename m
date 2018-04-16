Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEC76B0289
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:45:53 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l9so10614054qtp.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:45:53 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id q28si5303045qkh.252.2018.04.16.08.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:45:52 -0700 (PDT)
Date: Mon, 16 Apr 2018 10:45:48 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1804161123400.17807@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1804161043430.9622@nuc-kabylake>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161054410.17807@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804161018030.9397@nuc-kabylake>
 <alpine.LRH.2.02.1804161123400.17807@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 16 Apr 2018, Mikulas Patocka wrote:

> >
> > Or an increase in slab_max_order
>
> But that will increase it for all slabs (often senselessly - i.e.
> kmalloc-4096 would have order 4MB).

4MB? Nope.... That is a power of two slab so no wasted space even with
order 0.

Its not a senseless increase. The more objects you fit into a slab page
the higher the performance of the allocator.


> I need to increase it just for dm-bufio slabs.

If you do this then others will want the same...
