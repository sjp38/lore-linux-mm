Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k19HS2Oa019755
	for <linux-mm@kvack.org>; Thu, 9 Feb 2006 12:28:02 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k19HS2N6111386
	for <linux-mm@kvack.org>; Thu, 9 Feb 2006 12:28:02 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k19HS2lY022418
	for <linux-mm@kvack.org>; Thu, 9 Feb 2006 12:28:02 -0500
Subject: Re: [RFC] Removing page->flags
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <aec7e5c30602081850n772005bckf729683f446fb2a9@mail.gmail.com>
References: <1139381183.22509.186.camel@localhost>
	 <1139427478.9452.6.camel@localhost.localdomain>
	 <aec7e5c30602081850n772005bckf729683f446fb2a9@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 09 Feb 2006 09:27:55 -0800
Message-Id: <1139506075.9209.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-02-09 at 11:50 +0900, Magnus Damm wrote:
> I realize that if struct page size is not a power of two we will end
> up with struct page elements that cross a lot of page boundaries. But
> is that really a problem? I thought we were safe if:
> 
> 1) struct page could be any size
> 2) zones have to start and end at pfn:s that are a multiple of
> PAGE_SIZE
> 3) for sparsemem, the smallest section size is 1 << (PAGE_SIZE * 2).

Yeah, I've thought through some scenarios and I can't think of any where
it breaks unless the section size is really small, or a
non-power-of-two.  But, I don't think it is as feasible for DISCONTIGMEM
or normal FLATMEM configurations.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
