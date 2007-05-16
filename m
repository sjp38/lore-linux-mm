Date: Wed, 16 May 2007 08:53:41 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
Message-ID: <20070516125341.GS26766@think.oraclecorp.com>
References: <20070318233008.GA32597093@melbourne.sgi.com> <18993.1179310769@redhat.com> <1179317360.2859.225.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1179317360.2859.225.camel@shinybook.infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: David Howells <dhowells@redhat.com>, David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 16, 2007 at 08:09:19PM +0800, David Woodhouse wrote:
> On Wed, 2007-05-16 at 11:19 +0100, David Howells wrote:
> > The start and end points passed to block_prepare_write() delimit the region of
> > the page that is going to be modified.  This means that prepare_write()
> > doesn't need to fill it in if the page is not up to date. 
> 
> Really? Is it _really_ going to be modified? Even if the pointer
> userspace gave to write() is bogus, and is going to fault half-way
> through the copy_from_user()?

This is why there are so many variations on copy_from_user that zero on
faults.  One way or another, the prepare_write/commit_write pair are
responsible for filling it in.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
