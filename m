Date: Fri, 9 Jun 2000 00:03:54 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Allocating a page of memory with a given physical address
Message-ID: <20000609000354.G3886@redhat.com>
References: <yttd7lrq0ok.fsf@serpe.mitica> <20000608225108Z131165-245+107@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608225108Z131165-245+107@kanga.kvack.org>; from ttabi@interactivesi.com on Thu, Jun 08, 2000 at 05:27:42PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 08, 2000 at 05:27:42PM -0500, Timur Tabi wrote:
> 
> Unfortunately, that's not an option.  We need to be able to reserve/allocate
> pages in a driver's init_module() function, and I don't mean drivers that are
> compiled with the kernel.  We need to be able to ship a stand-alone driver that
> can work with pretty much any Linux distro of a particular version (e.g. we can
> say that only 2.4.14 and above is supported). 

About the only thing you could do would be to keep allocating pages until
you get one with the desired properties.  The kernel won't make any
guarantees about being able to free specific pages for you.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
