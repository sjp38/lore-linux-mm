Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03A346B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:25:33 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y2so958754qki.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:25:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c124si15365869qkd.182.2018.04.16.08.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:25:32 -0700 (PDT)
Date: Mon, 16 Apr 2018 11:25:30 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.DEB.2.20.1804161018030.9397@nuc-kabylake>
Message-ID: <alpine.LRH.2.02.1804161123400.17807@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com> <alpine.LRH.2.02.1804161054410.17807@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1804161018030.9397@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>



On Mon, 16 Apr 2018, Christopher Lameter wrote:

> On Mon, 16 Apr 2018, Mikulas Patocka wrote:
> 
> > > Please clarify further, thanks!
> > > Mike
> >
> > Yes, using a slab cache currently doesn't avoid this rouding (it needs the
> > SLAB_MINIMIZE_WASTE patch to do that).
> 
> Or an increase in slab_max_order

But that will increase it for all slabs (often senselessly - i.e. 
kmalloc-4096 would have order 4MB).

I need to increase it just for dm-bufio slabs.

Mikulas
