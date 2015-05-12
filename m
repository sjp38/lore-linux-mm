Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA0D6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 10:39:41 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so15030779pdb.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 07:39:41 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id b2si9243575pdf.235.2015.05.12.07.39.39
        for <linux-mm@kvack.org>;
        Tue, 12 May 2015 07:39:40 -0700 (PDT)
Date: Tue, 12 May 2015 10:39:37 -0400 (EDT)
Message-Id: <20150512.103937.434422170476918731.davem@davemloft.net>
Subject: Re: [PATCH 00/10] Refactor netdev page frags and move them into mm/
From: David Miller <davem@davemloft.net>
In-Reply-To: <20150511133652.cd885d654213fe4161da0d87@linux-foundation.org>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
	<20150510.191758.2130017622255857830.davem@davemloft.net>
	<20150511133652.cd885d654213fe4161da0d87@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org, linux-mm@kvack.org, eric.dumazet@gmail.com

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 11 May 2015 13:36:52 -0700

> On Sun, 10 May 2015 19:17:58 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
> 
>> > 4.9%	build_skb		3.8%	__napi_alloc_skb
>> > 2.5%	__alloc_rx_skb
>> > 1.9%	__napi_alloc_skb
>> 
>> I like this series, but again I need to see feedback from some
>> mm folks before I can consider applying it.
> 
> The MM part looks OK to me - it's largely moving code out of net/ into
> mm/.  It's a bit weird and it's unclear whether the code will gain
> other callers, but putting it in mm/ increase the likelihood that some other
> subsystem will use it.
> 
> Please merge it via a net tree when ready.

Ok, will do that now, thanks Andrew!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
