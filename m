Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3046B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 01:32:10 -0400 (EDT)
Subject: Re: mprotect pgprot handling weirdness
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1270530566.13812.28.camel@pasglop>
References: <1270530566.13812.28.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 06 Apr 2010 15:32:06 +1000
Message-ID: <1270531926.13812.29.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-04-06 at 15:09 +1000, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> While looking at untangling a bit some of the mess with vm_flags and
> pgprot (*), I notices a few things I can't quite explain... they may ..
> or may not be bugs, but I though it was worth mentioning:

 And another one:

- vma_wants_writenotify():

	/* The open routine did something to the protections already? */
	if (pgprot_val(vma->vm_page_prot) !=
	    pgprot_val(vm_get_page_prot(vm_flags)))
		return 0;

That's going to blow if any -other- prot bit is used here.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
