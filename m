Message-ID: <3A705CAF.70909@valinux.com>
Date: Thu, 25 Jan 2001 10:04:47 -0700
From: Jeff Hartmann <jhartmann@valinux.com>
MIME-Version: 1.0
Subject: Re: ioremap_nocache problem?
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
		<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600 <20010125155345Z131181-221+38@kanga.kvack.org> <20010125165001Z132264-460+11@vger.kernel.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Roman Zippel <roman@augan.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:

> ** Reply to message from Roman Zippel <roman@augan.com> on Thu, 25 Jan 2001
> 17:44:51 +0100
> 
> 
> 
>> set_bit(PG_reserved, &page->flags);
>> 	ioremap();
>> 	...
>> 	iounmap();
>> 	clear_bit(PG_reserved, &page->flags);
> 
> 
> The problem with this is that between the ioremap and iounmap, the page is
> reserved.  What happens if that page belongs to some disk buffer or user
> process, and some other process tries to free it.  Won't that cause a problem?

	The page can't belong to some other process/kernel component.  You own 
the page if you allocated it.  The kernel will only muck with memory you 
allocated if its GFP_HIGHMEM, or under certain circumstances if you map 
it into a user process (There are several rules here and I won't go into 
them, look at the DRM mmap setup for a start if your interested.)  This 
is the correct ordering of the calls (I was the one who added support to 
the kernel to ioremap real ram, trust me.)

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
