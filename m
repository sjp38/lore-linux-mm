Date: Thu, 25 Jan 2001 11:11:04 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <3A705CAF.70909@valinux.com>
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
	<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600 <20010125155345Z131181-221+38@kanga.kvack.org>
	<20010125165001Z132264-460+11@vger.kernel.org>
Subject: Re: ioremap_nocache problem?
Message-Id: <20010125170824Z131181-224+39@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Hartmann <jhartmann@valinux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Thu, 25 Jan
2001 10:04:47 -0700


> > The problem with this is that between the ioremap and iounmap, the page is
> > reserved.  What happens if that page belongs to some disk buffer or user
> > process, and some other process tries to free it.  Won't that cause a problem?
> 
> 	The page can't belong to some other process/kernel component.  You own 
> the page if you allocated it.  

Ok, my mistake.  I wasn't paying attention to the "get_free_pages" call.  My
problem is that I'm ioremap'ing someone else's page, but my hardware sits on the
memory bus disguised as real memory, and so I need to poke around the 4GB space
trying to find it.


> (I was the one who added support to 
> the kernel to ioremap real ram, trust me.)

I really appreciate that feature, because it helps me a lot.  Any
recommendations on how I can do what I do without causing any problems?  Right
now, my driver never calls iounmap on memory that's in real RAM, even when it
exits.  Fortunately, the driver isn't supposed to exit, so all it does is waste
a few KB of virtual memory.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
