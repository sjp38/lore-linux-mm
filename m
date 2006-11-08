Message-ID: <45520014.90503@shadowen.org>
Date: Wed, 08 Nov 2006 16:04:36 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3]: leak tracking for kmalloc node
References: <20061030141454.GB7164@lst.de> <84144f020610300632i799214a6p255e1690a93a95d4@mail.gmail.com> <4551E795.3090805@shadowen.org> <Pine.LNX.4.64.0611081652020.13867@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0611081652020.13867@sbz-30.cs.Helsinki.FI>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka J Enberg wrote:
> Hi Andy,
> 
> On Wed, 8 Nov 2006, Andy Whitcroft wrote:
>> I can give this a test, what is it based on...
> 
> While you are at it, could you please give Christoph's NUMA leak tracking 
> patch a spin too? I have included a rediffed version of it on top of 
> my alloc path cleanup patch. Thanks!

Ok, submitted both of these for testing on a variety of architectures,
mostly NUMA's will let you know what happens.  I'd expect the results on
TKO by tommorrow; someone has just dropped -rc5 and -rc5-mm1 on us :).

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
