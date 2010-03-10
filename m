Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BC4CA6B0082
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 02:16:16 -0500 (EST)
Date: Tue, 09 Mar 2010 23:16:35 -0800 (PST)
Message-Id: <20100309.231635.199019630.davem@davemloft.net>
Subject: Re: further plans on bootmem, was: Re: -
 bootmem-avoid-dma32-zone-by-default.patch removed from -mm tree
From: David Miller <davem@davemloft.net>
In-Reply-To: <20100310000121.GA9985@cmpxchg.org>
References: <4B96B923.7020805@kernel.org>
	<20100309134902.171ba2ae.akpm@linux-foundation.org>
	<20100310000121.GA9985@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, yinghai@kernel.org, x86@kernel.org, linux-arch@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 10 Mar 2010 01:01:21 +0100

> I also found it weird that it makes x86 skip an allocator level that all
> the other architectures are using, and replaces it with 'generic' code that
> nobody but x86 is using (sparc, powerpc, sh and microblaze  appear to have
> lib/lmb.c at this stage and for this purpose? lmb was also suggested by
> benh [4] but I have to admit I do not understand Yinghai's response to it).

It kind of irked me that lmb was passed over for whatever vague reason
was given.

It works fine with memory hotplug on powerpc, so a lack of hotplug
support can't be an argument for not using it.

But hey, having yet another early memory allocator instead of making
one of the existing ones do what you want, that's fine right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
