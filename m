Message-ID: <3CE172C7.C250E7E8@zip.com.au>
Date: Tue, 14 May 2002 13:25:43 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page-flags.h
References: <20020501192737.R29327@suse.de> <3CD317DD.2C9FBD11@zip.com.au> <20020504013938.G30500@suse.de> <200205040646.g446kZrO008548@smtpzilla5.xs4all.nl>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ekonijn@xs4all.nl
Cc: Dave Jones <davej@suse.de>, Christoph Hellwig <hch@infradead.org>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Erik van Konijnenburg wrote:
> 
> ...
> For pagemap.h, just three functions are responsible for
> an 82Kb callgraph: page_cache_alloc, add_to_page_cache,
> wait_on_page_locked.

inlines in headers are just a pita.  I know it gets people
all excited but I'd say: make 'em macros.

___add_to_page_cache() can be just uninlined.  I intend
to gang-add pages into the cache and LRU anyway, so that
function should become for "occasional use only" anyway.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
