Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3OFj5DY015914
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 11:45:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OFhm3O154098
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 11:43:48 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k3OFhlSA029367
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 11:43:47 -0400
Message-ID: <444CF232.5000003@watson.ibm.com>
Date: Mon, 24 Apr 2006 11:43:46 -0400
From: Hubertus Franke <frankeh@watson.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 1/8] Page host virtual assist: unused / free pages.
References: <20060424123423.GB15817@skybase> <200604241649.24792.ak@suse.de> <1145890749.5241.12.camel@localhost> <200604241706.27221.ak@suse.de>
In-Reply-To: <200604241706.27221.ak@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: schwidefsky@de.ibm.com, linux-mm@kvack.org, akpm@osdl.org, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Monday 24 April 2006 16:59, Martin Schwidefsky wrote:
> 
> 
>>Ok, sounds reasonable. Do we need to drop the _hva name component? If we
>>do that then something like page_hva_unmap_all will be named
>>page_unmap_all which might be a bit confusing as well.
> 
> 
> I would drop it because it seems like a very s390 specific term.
> 
> -Andi

First, let's decide whether the functionality and the page states
should be considered an "explicit concept" within linux like for instance
the KMAP.

So residency information of the hypervisor is thus exposed in the OS.
Having 3 or 4 states which seem easily understood ( unused, stable, volatile, p-volatile )
seems easy enough to us.

We can drop the _hva_ from the function calls and the name collisions we can
solved differently or leave them there with _hva_ or what ever name makes sense.
They don't show up in the general code path anyway.

Anybody else have a thought on this, Andrew ?

-- Hubertus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
