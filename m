Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 249E06B0038
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 13:30:51 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so4462541pad.8
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 10:30:50 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id sb3si8471437pac.220.2014.10.12.10.30.50
        for <linux-mm@kvack.org>;
        Sun, 12 Oct 2014 10:30:50 -0700 (PDT)
Date: Sun, 12 Oct 2014 13:30:47 -0400 (EDT)
Message-Id: <20141012.133047.427141450441745027.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAAmzW4Nrzp8TKurmevqmAV5kVRP2af1wZKqYcYH9RXroTZavpw@mail.gmail.com>
References: <20141011.221510.1574777235900788349.davem@davemloft.net>
	<CAAmzW4Nrzp8TKurmevqmAV5kVRP2af1wZKqYcYH9RXroTZavpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org

From: Joonsoo Kim <js1304@gmail.com>
Date: Mon, 13 Oct 2014 02:22:15 +0900

> Could you test below patch?
> If it fixes your problem, I will send it with proper description.

It works, I just tested using ARCH_KMALLOC_MINALIGN which would be
better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
