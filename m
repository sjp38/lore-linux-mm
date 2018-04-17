Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB7B6B0273
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:40:18 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id k32so6105129ywh.21
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:40:18 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id m61si1227570qtd.184.2018.04.17.07.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:40:17 -0700 (PDT)
Date: Tue, 17 Apr 2018 09:40:15 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1804161650170.7237@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1804170939420.17557@nuc-kabylake>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
 <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com> <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com>
 <alpine.LRH.2.02.1804161054410.17807@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804161018030.9397@nuc-kabylake> <alpine.LRH.2.02.1804161123400.17807@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804161043430.9622@nuc-kabylake>
 <alpine.LRH.2.02.1804161532480.19492@file01.intranet.prod.int.rdu2.redhat.com> <b0e6ccf6-06ce-e50b-840e-c8d3072382fd@suse.cz> <alpine.LRH.2.02.1804161650170.7237@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, 16 Apr 2018, Mikulas Patocka wrote:

> dm-bufio deals gracefully with allocation failure, because it preallocates
> some buffers with vmalloc, but other subsystems may not deal with it and
> they cound return ENOMEM randomly or misbehave in other ways. So, the
> "SLAB_MINIMIZE_WASTE" flag is also saying that the allocation may fail and
> the caller is prepared to deal with it.
>
> The slub subsystem does actual fallback to low-order when the allocation
> fails (it allows different order for each slab in the same cache), but
> slab doesn't fallback and you get NULL if higher-order allocation fails.
> So, SLAB_MINIMIZE_WASTE is needed for slab because it will just randomly
> fail with higher order.

Fix Slab instead of adding a flag that is only useful for one allocator?
