Date: Thu, 08 Jun 2000 17:27:42 -0500
From: Timur Tabi <ttabi@interactivesi.com>
References: <20000608220756Z131165-245+106@kanga.kvack.org><20000608220756Z131165-245+106@kanga.kvack.org><20000608222138Z131165-281+94@kanga.kvack.org>
In-Reply-To: <yttd7lrq0ok.fsf@serpe.mitica>
References: Timur Tabi's message of "Thu, 08 Jun 2000 16:58:13 -0500"
Subject: Re: Allocating a page of memory with a given physical address
Message-Id: <20000608225108Z131165-245+107@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from "Juan J. Quintela" <quintela@fi.udc.es> on 09 Jun 2000
00:15:39 +0200


> Try to grep the kernel for mem_map_reserve uses, it does something
> similar, and can be similar to what you want to do.  Notice that you
> need to reserve the page *soon* in the boot process.

Unfortunately, that's not an option.  We need to be able to reserve/allocate
pages in a driver's init_module() function, and I don't mean drivers that are
compiled with the kernel.  We need to be able to ship a stand-alone driver that
can work with pretty much any Linux distro of a particular version (e.g. we can
say that only 2.4.14 and above is supported). 

For the time being, we can work with a patch to the kernel, but that patch be
relatively generic, and it must support our dynamically loadable driver.




--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
