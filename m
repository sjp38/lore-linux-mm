Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 432E86B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 12:25:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189so3045570pfp.1
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:25:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t23sor1067481pgn.37.2018.04.19.09.25.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 09:25:51 -0700 (PDT)
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com>
 <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com>
 <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <6260a8af-3166-94d3-9441-104d342ab7a1@gmail.com>
Date: Thu, 19 Apr 2018 09:25:48 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On 04/19/2018 09:12 AM, Mikulas Patocka wrote:
> 
> 
> These bugs are hard to reproduce because vmalloc falls back to kmalloc
> only if memory is fragmented.
> 

This sentence is wrong.

.... because kvmalloc() falls back to vmalloc() ...
