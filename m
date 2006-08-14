From: Keith Owens <kaos@ocs.com.au>
Subject: Re: [PATCH 1/1] network memory allocator. 
In-reply-to: Your message of "Mon, 14 Aug 2006 15:04:03 +0400."
             <20060814110359.GA27704@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Mon, 14 Aug 2006 22:07:48 +1000
Message-ID: <9286.1155557268@ocs10w.ocs.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Evgeniy Polyakov (on Mon, 14 Aug 2006 15:04:03 +0400) wrote:
>Network tree allocator can be used to allocate memory for all network
>operations from any context....
>...
>Design of allocator allows to map all node's pages into userspace thus
>allows to have true zero-copy support for both sending and receiving
>dataflows.

Is that true for architectures with virtually indexed caches?  How do
you avoid the cache aliasing problems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
