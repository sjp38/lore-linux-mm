Date: Fri, 15 Oct 2004 16:34:40 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RESEND][PATCH 4/6] Add page becoming writable notification
Message-ID: <20041015153440.GA22607@infradead.org>
References: <20041014203545.GA13639@infradead.org> <24449.1097780701@redhat.com> <28544.1097852703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28544.1097852703@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 15, 2004 at 04:05:03PM +0100, David Howells wrote:
> 
> > > +	/* notification that a page is about to become writable */
> > > +	int (*page_mkwrite)(struct page *page);
> > 
> > This doesn't fit into address_space operations at all.  The vm_operation
> > below is enough.
> 
> Filesystems shouldn't be overloading vm_operations on ordinary files, or so
> I've been instructed.

huh?  that doesn't make any sense.  if a filesystem needs to do something
special win regards to the VM it should overload vm_operations.  Currently
that's only ncpfs and xfs.

> > This prototype shows pretty much that splitting it out doesn't make much
> > sense.  Why not add a goto reuse_page; where you call it currently and
> > append it at the end of do_wp_page?
> 
> Judging by the CodingStyle doc - which you like throwing at me - it should be
> split into a separate inline function. I could come up with a better name, I
> suppose to keep Willy happy too - perhaps make_pte_writable(); it's just that
> I wanted to name it to show its derivation.

Splitting in helpers makes sense if there's a sane interface.  The number of
arguments doesn't exactly imply that it's the case here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
