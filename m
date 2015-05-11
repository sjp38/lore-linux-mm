Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DCD7C6B006E
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:36:54 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so118561229pac.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 13:36:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i6si19342825pdr.64.2015.05.11.13.36.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 13:36:53 -0700 (PDT)
Date: Mon, 11 May 2015 13:36:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/10] Refactor netdev page frags and move them into mm/
Message-Id: <20150511133652.cd885d654213fe4161da0d87@linux-foundation.org>
In-Reply-To: <20150510.191758.2130017622255857830.davem@davemloft.net>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
	<20150510.191758.2130017622255857830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org, linux-mm@kvack.org, eric.dumazet@gmail.com

On Sun, 10 May 2015 19:17:58 -0400 (EDT) David Miller <davem@davemloft.net> wrote:

> > 4.9%	build_skb		3.8%	__napi_alloc_skb
> > 2.5%	__alloc_rx_skb
> > 1.9%	__napi_alloc_skb
> 
> I like this series, but again I need to see feedback from some
> mm folks before I can consider applying it.

The MM part looks OK to me - it's largely moving code out of net/ into
mm/.  It's a bit weird and it's unclear whether the code will gain
other callers, but putting it in mm/ increase the likelihood that some other
subsystem will use it.

Please merge it via a net tree when ready.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
