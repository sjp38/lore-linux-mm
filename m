Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 852A66B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 03:30:54 -0400 (EDT)
Subject: Re: Arch specific mmap attributes (Was: mprotect pgprot handling
 weirdness)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100406151751.7E4E.A69D9226@jp.fujitsu.com>
References: <20100406143928.7E4B.A69D9226@jp.fujitsu.com>
	 <1270534061.13812.56.camel@pasglop>
	 <20100406151751.7E4E.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 06 Apr 2010 17:30:44 +1000
Message-ID: <1270539044.13812.65.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-04-06 at 15:24 +0900, KOSAKI Motohiro wrote:

> I guess you haven't catch my intention. I didn't say we have to remove 
> PROT_SAO and VM_SAO.
> I mean mmap(PROT_SAO) is ok, it's only append new flag, not change exiting
> flags meanings. I'm only against mprotect(PROT_NONE) turn off PROT_SAO
> implicitely.
> 
> IOW I recommend we use three syscall
> 	mmap()		create new mappings
> 	mprotect()	change a protection of mapping (as a name)
> 	mattribute(): (or similar name)
> 			change an attribute of mapping (e.g. PROT_SAO or
> 			another arch specific flags)
> 
> I'm not against changing mm/protect.c for PROT_SAO.

Ok, I see. No biggie. The main deal remains how we want to do that
inside the kernel :-) I think the less horrible options here are
to either extend vm_flags to always be 64-bit, or add a separate
vm_map_attributes flag, and add the necessary bits and pieces to
prevent merge accross different attribute vma's.

The more I try to hack it into vm_page_prot, the more I hate that
option.

Cheers
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
