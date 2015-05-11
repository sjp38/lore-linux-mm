Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 569136B0038
	for <linux-mm@kvack.org>; Sun, 10 May 2015 20:52:19 -0400 (EDT)
Received: by pdea3 with SMTP id a3so134627849pde.3
        for <linux-mm@kvack.org>; Sun, 10 May 2015 17:52:19 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id kx13si15832730pab.98.2015.05.10.17.52.18
        for <linux-mm@kvack.org>;
        Sun, 10 May 2015 17:52:18 -0700 (PDT)
Date: Sun, 10 May 2015 20:52:13 -0400 (EDT)
Message-Id: <20150510.205213.202914226916051307.davem@davemloft.net>
Subject: Re: [PATCH 01/10] net: Use cached copy of pfmemalloc to avoid
 accessing page
From: David Miller <davem@davemloft.net>
In-Reply-To: <554FF14B.4050901@gmail.com>
References: <20150507041140.1873.58533.stgit@ahduyck-vm-fedora22>
	<20150510.191851.414324528131774160.davem@davemloft.net>
	<554FF14B.4050901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.duyck@gmail.com
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, eric.dumazet@gmail.com

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sun, 10 May 2015 17:01:15 -0700

> The reason for the difference between the two is that in the case of
> netdev_alloc_skb/frag the netdev_alloc_cache can only be accessed with
> IRQs disabled, whereas in the napi_alloc_skb case we can access the
> napi_alloc_cache at any point in the function.  Either way I am going
> to be stuck with differences because of the local_irq_save/restore
> that must be called when accessing the page frag cache that doesn't
> exist in the napi case.

I see, thanks for explaining.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
