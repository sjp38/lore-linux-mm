Date: Wed, 1 May 2002 18:34:14 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: page-flags.h
Message-ID: <20020501183414.A28790@infradead.org>
References: <20020501192737.R29327@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020501192737.R29327@suse.de>; from davej@suse.de on Wed, May 01, 2002 at 07:27:37PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@suse.de>
Cc: kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2002 at 07:27:37PM +0200, Dave Jones wrote:
> A new header file appeared in 2.5.12, include/linux/page-flags.h
> Currently, there are many places that need this, but instead of
> including it, they are including <linux/mm.h> which in turn sucks
> in zillions of other files.
> 
> According to a comment in mm.h, there are 119 places that need
> fixing here.
> 
> Method:
> o  Remove the #include <linux/page-flags.h> from mm.h
> o  Compile, and see what breaks.
> o  Add #include <linux/page-flags.h> to file compilation died on.
> o  Try removing the <linux/mm.h> include also, but this may not
>    be possible in all circumstances.

This step is wasted work - it will NEVER compile.  Rationale:
the page flags operate on page->flags and without having the definition
of struct page from mm.h this won't do.

The better idea is IMHO to replace page-flags.h by page.h that also
contains the definition of struct page.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
