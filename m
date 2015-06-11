Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id B9EDF6B0038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 18:55:57 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so1852594igb.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:55:57 -0700 (PDT)
Received: from mail-ig0-x241.google.com (mail-ig0-x241.google.com. [2607:f8b0:4001:c05::241])
        by mx.google.com with ESMTPS id 15si1577580ioo.98.2015.06.11.15.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 15:55:57 -0700 (PDT)
Received: by igdj8 with SMTP id j8so256586igd.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:55:57 -0700 (PDT)
Message-ID: <1434063355.27504.62.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Jun 2015 15:55:55 -0700
In-Reply-To: <557A0949.3020705@fb.com>
References: 
	<71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
	 <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5579FABE.4050505@fb.com>
	 <1434057733.27504.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <557A0949.3020705@fb.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: Shaohua Li <shli@fb.com>, netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, 2015-06-11 at 18:18 -0400, Chris Mason wrote:

> But, is there any fallback to a single page allocation somewhere else?
> If this is the only way to get memory, we might want to add a single
> alloc_page path that won't trigger compaction but is at least able to
> wait for kswapd to make progress.

Sure, there is a fallback to order-0 in both skb_page_frag_refill() and
alloc_skb_with_frags() 

They also use __GFP_NOWARN | __GFP_NORETRY


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
