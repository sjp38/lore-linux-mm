Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 78CC06B01BD
	for <linux-mm@kvack.org>; Sun, 30 May 2010 06:05:15 -0400 (EDT)
Message-ID: <4C023854.3090002@cs.helsinki.fi>
Date: Sun, 30 May 2010 13:05:08 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [BUG] slub crashes on dma allocations
References: <20100526153757.GB2232@osiris.boeblingen.de.ibm.com> <alpine.DEB.2.00.1005270916220.5762@router.home> <20100527190440.GA2205@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20100527190440.GA2205@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Heiko Carstens wrote:
> On Thu, May 27, 2010 at 09:17:17AM -0500, Christoph Lameter wrote:
>> So S390 has NUMA and the minalign is allowing very small slabs of 8/16/32 bytes?
> 
> No NUMA, but minalign is 8.
> 
>> Try this patch
>>
>> From: Christoph Lameter <cl@linux-foundation.org>
>> Subject: SLUB: Allow full duplication of kmalloc array for 390
>>
>> Seems that S390 is running out of kmalloc caches.
>>
>> Increase the number of kmalloc caches to a safe size.
>>
>> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Yes, that fixes the bug. Thanks!

We need this for .33 and .34 stable, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
