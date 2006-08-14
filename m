Date: Mon, 14 Aug 2006 16:20:50 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Message-ID: <20060814122049.GC18321@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru> <9286.1155557268@ocs10w.ocs.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <9286.1155557268@ocs10w.ocs.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Owens <kaos@ocs.com.au>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 14, 2006 at 10:07:48PM +1000, Keith Owens (kaos@ocs.com.au) wrote:
> Evgeniy Polyakov (on Mon, 14 Aug 2006 15:04:03 +0400) wrote:
> >Network tree allocator can be used to allocate memory for all network
> >operations from any context....
> >...
> >Design of allocator allows to map all node's pages into userspace thus
> >allows to have true zero-copy support for both sending and receiving
> >dataflows.
> 
> Is that true for architectures with virtually indexed caches?  How do
> you avoid the cache aliasing problems?

Pages are preallocated and stolen from main memory allocator, what is
the problem with that caches? Userspace can provide enough offset so
that pages would not create aliases - it is usuall mmap.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
