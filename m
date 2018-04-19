Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 826F06B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 12:28:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e64so3766716qkb.16
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:28:43 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z3si5143036qkc.239.2018.04.19.09.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 09:28:42 -0700 (PDT)
Date: Thu, 19 Apr 2018 12:28:41 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <6260a8af-3166-94d3-9441-104d342ab7a1@gmail.com>
Message-ID: <alpine.LRH.2.02.1804191228080.31175@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <6260a8af-3166-94d3-9441-104d342ab7a1@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Thu, 19 Apr 2018, Eric Dumazet wrote:

> 
> 
> On 04/19/2018 09:12 AM, Mikulas Patocka wrote:
> > 
> > 
> > These bugs are hard to reproduce because vmalloc falls back to kmalloc
> > only if memory is fragmented.
> > 
> 
> This sentence is wrong.
> 
> .... because kvmalloc() falls back to vmalloc() ...

Yes. There should be "falls back to vmalloc()".

Mikulas
