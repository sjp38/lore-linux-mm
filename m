Subject: Re: limit on number of kmapped pages
References: <y7rsnmav0cv.fsf@sytry.doc.ic.ac.uk>
	<m1r91udt59.fsf@frodo.biederman.org>
	<y7rofwxeqin.fsf@sytry.doc.ic.ac.uk>
	<20010125181621.W11607@redhat.com>
From: David Wragg <dpw@doc.ic.ac.uk>
Date: 25 Jan 2001 23:53:16 +0000
In-Reply-To: "Stephen C. Tweedie"'s message of "Thu, 25 Jan 2001 18:16:21 +0000"
Message-ID: <y7rwvbjmbo3.fsf@sytry.doc.ic.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:
> On Wed, Jan 24, 2001 at 12:35:12AM +0000, David Wragg wrote:
> > 
> > > And why do the pages need to be kmapped? 
> > 
> > They only need to be kmapped while data is being copied into them.
> 
> But you only need to kmap one page at a time during the copy.  There
> is absolutely no need to copy the whole chunk at once.

The chunks I'm copying are always smaller than a page.  Usually they
are a few hundred bytes.

Though because I'm copying into the pages in a bottom half, I'll have
to use kmap_atomic.  After a page is filled, it is put into the page
cache.  So they have to be allocated with page_cache_alloc(), hence
__GFP_HIGHMEM and the reason I'm bothering with kmap at all.


David Wragg
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
