Date: Wed, 15 May 2002 13:38:00 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: page-flags.h
Message-ID: <20020515133800.A25614@infradead.org>
References: <20020501192737.R29327@suse.de> <3CD317DD.2C9FBD11@zip.com.au> <20020504013938.G30500@suse.de> <200205040646.g446kZrO008548@smtpzilla5.xs4all.nl> <3CE172C7.C250E7E8@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3CE172C7.C250E7E8@zip.com.au>; from akpm@zip.com.au on Tue, May 14, 2002 at 01:25:43PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: ekonijn@xs4all.nl, Dave Jones <davej@suse.de>, Christoph Hellwig <hch@infradead.org>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2002 at 01:25:43PM -0700, Andrew Morton wrote:
> Erik van Konijnenburg wrote:
> > 
> > ...
> > For pagemap.h, just three functions are responsible for
> > an 82Kb callgraph: page_cache_alloc, add_to_page_cache,
> > wait_on_page_locked.
> 
> inlines in headers are just a pita.  I know it gets people
> all excited but I'd say: make 'em macros.
> 
> ___add_to_page_cache() can be just uninlined.  I intend
> to gang-add pages into the cache and LRU anyway, so that
> function should become for "occasional use only" anyway.

I'm all for it.  I nfact I have a patch to rename it to link_to_page_cache()
and make it an uninline FASTCALL pending, waiting for the buffer_head.h
patch going to Linus first.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
