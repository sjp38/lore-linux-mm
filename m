Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF9B6B0038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 20:02:24 -0400 (EDT)
Received: by igbzc4 with SMTP id zc4so1206650igb.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:02:24 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id zx8si116841igc.15.2015.06.11.17.02.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 17:02:23 -0700 (PDT)
Received: by igbsb11 with SMTP id sb11so1161286igb.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:02:23 -0700 (PDT)
Message-ID: <1434067342.27504.73.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Jun 2015 17:02:22 -0700
In-Reply-To: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
References: 
	<0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com, Eric Dumazet <edumazet@google.com>

On Thu, 2015-06-11 at 16:50 -0700, Shaohua Li wrote:
> We saw excessive direct memory compaction triggered by skb_page_frag_refill.
> This causes performance issues and add latency. Commit 5640f7685831e0
> introduces the order-3 allocation. According to the changelog, the order-3
> allocation isn't a must-have but to improve performance. But direct memory
> compaction has high overhead. The benefit of order-3 allocation can't
> compensate the overhead of direct memory compaction.

> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Chris Mason <clm@fb.com>
> Cc: Debabrata Banerjee <dbavatar@gmail.com>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
