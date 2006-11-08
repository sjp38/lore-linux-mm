Message-ID: <4551E795.3090805@shadowen.org>
Date: Wed, 08 Nov 2006 14:20:05 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3]: leak tracking for kmalloc node
References: <20061030141454.GB7164@lst.de> <84144f020610300632i799214a6p255e1690a93a95d4@mail.gmail.com>
In-Reply-To: <84144f020610300632i799214a6p255e1690a93a95d4@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Hi,
> 
> On 10/30/06, Christoph Hellwig <hch@lst.de> wrote:
>> If we want to use the node-aware kmalloc in __alloc_skb we need
>> the tracker is responsible for leak tracking magic for it.  This
>> patch implements it.  The code is far too ugly for my taste, but it's
>> doing exactly what the regular kmalloc is doing and thus follows it's
>> style.
> 
> Yeah, the allocation paths are ugly. If only someone with NUMA machine
> could give this a shot so we can get it merged:
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=115952740803511&w=2
> 
> Should clean up NUMA kmalloc tracking too.

I can give this a test, what is it based on...

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
