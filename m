Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 33A756B006E
	for <linux-mm@kvack.org>; Sun, 19 Oct 2014 13:27:41 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so3700733pac.14
        for <linux-mm@kvack.org>; Sun, 19 Oct 2014 10:27:40 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id bt7si5652056pad.57.2014.10.19.10.27.39
        for <linux-mm@kvack.org>;
        Sun, 19 Oct 2014 10:27:40 -0700 (PDT)
Date: Sun, 19 Oct 2014 13:27:37 -0400 (EDT)
Message-Id: <20141019.132737.1392053813844289431.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141019153219.GA10644@ravnborg.org>
References: <20141018.135907.356113264227709132.davem@davemloft.net>
	<20141018.142335.1935310766779155342.davem@davemloft.net>
	<20141019153219.GA10644@ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sam@ravnborg.org
Cc: mroos@linux.ee, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Sam Ravnborg <sam@ravnborg.org>
Date: Sun, 19 Oct 2014 17:32:20 +0200

> This part:
> 
>> +		__attribute__ ((aligned(64)));
> 
> Could be written as __aligned(64)

I'll try to remember to sweep this up in sparc-next, thanks Sam.

We probably use this long-hand form in a lot of other places in
the sparc code too, so I'll try to do a full sweep.

Thanks again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
