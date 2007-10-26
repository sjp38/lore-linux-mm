Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9Q88L83057904
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 08:08:21 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9Q88LO01822970
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 10:08:21 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9Q88K27023536
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 10:08:21 +0200
Subject: Re: [patch 2/6] CONFIG_HIGHPTE vs. sub-page page tables.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1193385617.13638.3.camel@pasglop>
References: <20071025181520.880272069@de.ibm.com>
	 <20071025181901.212545095@de.ibm.com>  <1193345221.7018.18.camel@pasglop>
	 <1193384578.31831.6.camel@localhost>  <1193385617.13638.3.camel@pasglop>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 10:08:20 +0200
Message-Id: <1193386100.31831.13.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 18:00 +1000, Benjamin Herrenschmidt wrote:
> > > Interesting. That means I don't need to have a PTE page to be a struct
> > > page anymore ? I can have good use for that on powerpc as well... 
> > 
> > That would be good news. I'm curious, can you elaborate on what the use
> > case is?
> 
> When using 64K pages, we use 32K of PTEs and 32K of "extension". The
> extension thing is used when using HW 4K pages, to keep track of the
> subpages. On setups where that isn't needed, we can save memory by
> allocating half pages...

Ahh, that is exactly the same reason as for s390. Page tables with a
size that is sub-page.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
