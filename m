Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B461A6B006C
	for <linux-mm@kvack.org>; Sun, 10 May 2015 19:18:53 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so94982178pac.1
        for <linux-mm@kvack.org>; Sun, 10 May 2015 16:18:53 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id au5si15518640pbc.232.2015.05.10.16.18.52
        for <linux-mm@kvack.org>;
        Sun, 10 May 2015 16:18:52 -0700 (PDT)
Date: Sun, 10 May 2015 19:18:51 -0400 (EDT)
Message-Id: <20150510.191851.414324528131774160.davem@davemloft.net>
Subject: Re: [PATCH 01/10] net: Use cached copy of pfmemalloc to avoid
 accessing page
From: David Miller <davem@davemloft.net>
In-Reply-To: <20150507041140.1873.58533.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
	<20150507041140.1873.58533.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@redhat.com
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, eric.dumazet@gmail.com

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:11:40 -0700

> +	/* use OR instead of assignment to avoid clearing of bits in mask */
> +	if (pfmemalloc)
> +		skb->pfmemalloc = 1;
> +	skb->head_frag = 1;
 ...
> +	/* use OR instead of assignment to avoid clearing of bits in mask */
> +	if (nc->pfmemalloc)
> +		skb->pfmemalloc = 1;
> +	skb->head_frag = 1;

Maybe make these two cases more consistent by either accessing
nc->pfmemalloc or using a local variable in both cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
