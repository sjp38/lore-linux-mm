Date: Fri, 3 May 2002 09:24:36 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: page-flags.h
Message-ID: <20020503092436.A19267@infradead.org>
References: <20020501192737.R29327@suse.de> <20020501183414.A28790@infradead.org> <20020501200452.S29327@suse.de> <3CD1FB78.B3314F4B@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3CD1FB78.B3314F4B@zip.com.au>; from akpm@zip.com.au on Thu, May 02, 2002 at 07:52:40PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Dave Jones <davej@suse.de>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2002 at 07:52:40PM -0700, Andrew Morton wrote:
> > That's a good point, and something I completley overlooked.
> > I wonder if Andrew Morton (who I'm guessing wrote that comment
> > in mm.h) has some ingenious plan here..
> 
> who, me?
> 
> I'd envisaged those 119 files doing:
> 
> #include <linux/mm.h>
> #include <linux/page-flags.h>
> 
> so then anything which includes mm.h but doesn't do any PageFoo()
> operations doesn't have to process those macros.

Okay, that makes some sense.  I still think it's preferrable to
have <linux/page.h>  - many filesystems only need struct page, the
flags and few supporting functions, so do drivers using kiobufs.

Having these no need the rest of the MM internals is a good thing (TM).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
