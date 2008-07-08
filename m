Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m68DZr5P000388
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 09:35:53 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m68DZruK215522
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 09:35:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m68DZqGX005103
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 09:35:53 -0400
Subject: Re: [patch 1/6] mm: Allow architectures to define additional
	protection bits
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <1215497929.8970.207.camel@pasglop>
References: <20080618223254.966080905@linux.vnet.ibm.com>
	 <20080618223328.856102092@linux.vnet.ibm.com>
	 <20080701015301.3dc8749b.akpm@linux-foundation.org>
	 <1214920499.18690.10.camel@norville.austin.ibm.com>
	 <1215409956.8970.82.camel@pasglop>
	 <Pine.LNX.4.64.0807072143200.27181@blonde.site>
	 <1215469468.8970.143.camel@pasglop>  <1215497929.8970.207.camel@pasglop>
Content-Type: text/plain
Date: Tue, 08 Jul 2008 08:35:51 -0500
Message-Id: <1215524151.20459.4.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Paul Mackerras <paulus@au1.ibm.com>, Linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-07-08 at 16:18 +1000, Benjamin Herrenschmidt wrote:

> Andrew, what tree should this go via ? I have further powerpc patches
> depending on this one... so on one hand I'd be happy to take it, but
> on the other hand, it's more likely to clash with other things...

Andrew has asked that it go through Paul, which now means you.

"It'd be simpler if Paul were to merge this.  It doesn't conflict with
any pending work."
http://ozlabs.org/pipermail/linuxppc-dev/2008-July/058948.html

> 
> Maybe I should check how it applies on top of linux-next.

Looks pretty clean:

patching file include/linux/mman.h
patching file mm/mmap.c
patching file mm/mprotect.c
Hunk #1 succeeded at 237 (offset -2 lines).

Thanks,
Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
