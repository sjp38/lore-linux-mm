Received: from sgi.com (sgi.SGI.COM [192.48.153.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA00116
	for <linux-mm@kvack.org>; Fri, 19 Feb 1999 13:17:24 -0500
Date: Fri, 19 Feb 1999 10:11:06 -0800
From: kanoj@kulten.engr.sgi.com (Kanoj Sarcar)
Message-Id: <9902191011.ZM28911@kulten.engr.sgi.com>
In-Reply-To: Neil Booth <NeilB@earthling.net>
        "vmalloc.c question" (Feb 19,  7:24pm)
References: <36CD3BCE.9D2AE90E@earthling.net>
Subject: Re: vmalloc.c question
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Neil Booth <NeilB@earthling.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 19,  7:24pm, Neil Booth wrote:
> Subject: vmalloc.c question
> I have a simple question about vmalloc.c. I'm probably missing something
> obvious, but it appears to me that the list "vmlist" of the kernel's
> virtual memory areas is not protected by any kind of locking mechanism,
> and thus subject to races. (e.g. two CPUs trying to insert a new virtual
> memory block in the same place at the same time in get_vm_area).
>
> Or what am I missing?
>

Actually, the ia32 specific ioremap function also calls into the
get_vm_area() function. I was assuming that the giant kernel_lock
protects the "vmlist".

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
