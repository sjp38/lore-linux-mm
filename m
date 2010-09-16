Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC426B007E
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 06:04:37 -0400 (EDT)
Subject: Re: Reserved pages in PowerPC
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100916052311.GC2332@in.ibm.com>
References: <20100916052311.GC2332@in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Sep 2010 20:04:24 +1000
Message-ID: <1284631464.30449.85.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ankita Garg <ankita@in.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-09-16 at 10:53 +0530, Ankita Garg wrote:
> 
> With some debugging I found that that section has reserved pages. On
> instrumenting the memblock_reserve() and reserve_bootmem() routines, I can see
> that many of the memory areas are reserved for kernel and initrd by the
> memblock reserve() itself. reserve_bootmem then looks at the pages already
> reserved and marks them reserved. However, for the very last section, I see
> that bootmem reserves it but I am unable to find a corresponding reservation
> by the memblock code.

It's probably RTAS (firmware runtime services). I'ts instanciated at
boot from prom_init and we do favor high addresses for it below 1G iirc.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
