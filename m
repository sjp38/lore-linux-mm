Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 862126B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 15:22:31 -0400 (EDT)
Date: Wed, 26 Aug 2009 12:22:48 -0700 (PDT)
Message-Id: <20090826.122248.47485961.davem@davemloft.net>
Subject: Re: Page allocation failures in guest
From: David Miller <davem@davemloft.net>
In-Reply-To: <200908262148.59664.rusty@rustcorp.com.au>
References: <200908261147.17838.rusty@rustcorp.com.au>
	<20090826065501.7ab677b9@mjolnir.ossman.eu>
	<200908262148.59664.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: rusty@rustcorp.com.au
Cc: drzeus-list@drzeus.cx, avi@redhat.com, minchan.kim@gmail.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 26 Aug 2009 21:48:58 +0930

> Dave, can you push this to Linus ASAP?

Ok.

> Subject: virtio: net refill on out-of-memory
> 
> If we run out of memory, use keventd to fill the buffer.  There's a
> report of this happening: "Page allocation failures in guest",
> Message-ID: <20090713115158.0a4892b0@mjolnir.ossman.eu>
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
