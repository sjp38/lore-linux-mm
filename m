Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E9A7D6B00F9
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:14:30 -0500 (EST)
Subject: Re: [PATCH] generic debug pagealloc
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090303133610.cb771fef.akpm@linux-foundation.org>
References: <20090303160103.GB5812@localhost.localdomain>
	 <20090303133610.cb771fef.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 06 Mar 2009 20:14:20 +1100
Message-Id: <1236330860.7260.128.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-03-03 at 13:36 -0800, Andrew Morton wrote:
> Alternatively, we could just not do the kmap_atomic() at all.  i386
> won't be using this code and IIRC the only other highmem architecture
> is powerpc32, and ppc32 appears to also have its own DEBUG_PAGEALLOC
> implementation.  So you could remove the kmap_atomic() stuff and put
> 
Actually, ppc32 DEBUG_PAGEALLOC is busted in several ways and probably
unfixable (though this is still being debated).

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
