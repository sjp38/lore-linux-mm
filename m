Date: Wed, 1 May 2002 20:04:53 +0200
From: Dave Jones <davej@suse.de>
Subject: Re: page-flags.h
Message-ID: <20020501200452.S29327@suse.de>
References: <20020501192737.R29327@suse.de> <20020501183414.A28790@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020501183414.A28790@infradead.org>; from hch@infradead.org on Wed, May 01, 2002 at 06:34:14PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2002 at 06:34:14PM +0100, Christoph Hellwig wrote:
 > This step is wasted work - it will NEVER compile.  Rationale:
 > the page flags operate on page->flags and without having the definition
 > of struct page from mm.h this won't do.
 > 
 > The better idea is IMHO to replace page-flags.h by page.h that also
 > contains the definition of struct page.

That's a good point, and something I completley overlooked.
I wonder if Andrew Morton (who I'm guessing wrote that comment
in mm.h) has some ingenious plan here..

-- 
| Dave Jones.        http://www.codemonkey.org.uk
| SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
