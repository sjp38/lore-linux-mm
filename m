Date: Fri, 24 May 2002 13:20:59 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH] using page aging to shrink caches (pre8-ac5)
Message-ID: <20020524132059.A11342@infradead.org>
References: <200205180010.51382.tomlins@cam.org> <200205240728.45558.tomlins@cam.org> <20020524123535.A9618@infradead.org> <200205240814.25293.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200205240814.25293.tomlins@cam.org>; from tomlins@cam.org on Fri, May 24, 2002 at 08:14:25AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2002 at 08:14:25AM -0400, Ed Tomlinson wrote:
> On May 24, 2002 07:35 am, Christoph Hellwig wrote:
> > On Fri, May 24, 2002 at 07:28:45AM -0400, Ed Tomlinson wrote:
> > > Comments, questions and feedback very welcome,
> >
> > Just from a short look:
> >
> > What about doing mark_page_accessed in kmem_touch_page?
> 
> mark_page_accessed expects a page struct.  kmem_touch_page takes an
> address in the page, converts it to a kernel address and then marks the page.

Of course after the virt_to_page..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
