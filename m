Date: Fri, 26 Jan 2001 10:39:31 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: ioremap_nocache problem?
Message-ID: <20010126103931.C11607@redhat.com>
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org> <20010123165117Z131182-221+34@kanga.kvack.org> <20010125155345Z131181-221+38@kanga.kvack.org> <3A705802.5C4DD2F2@augan.com> <20010125164707Z131181-222+39@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010125164707Z131181-222+39@kanga.kvack.org>; from ttabi@interactivesi.com on Thu, Jan 25, 2001 at 10:49:50AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Roman Zippel <roman@augan.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jan 25, 2001 at 10:49:50AM -0600, Timur Tabi wrote:
> 
> > set_bit(PG_reserved, &page->flags);
> > 	ioremap();
> > 	...
> > 	iounmap();
> > 	clear_bit(PG_reserved, &page->flags);
> 
> The problem with this is that between the ioremap and iounmap, the page is
> reserved.  What happens if that page belongs to some disk buffer or user
> process, and some other process tries to free it.  Won't that cause a problem?

It depends on how it is being used, but yes, it is likely to --- page
reference counts won't be updated properly on reserved pages, for
example.  Why on earth do you want to do ioremap of something like a
page cache page, though?  That is _not_ what ioremap is designed for!

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
