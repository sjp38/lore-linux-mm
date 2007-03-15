Date: Thu, 15 Mar 2007 13:38:59 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
Message-ID: <20070315123859.GC8321@wotan.suse.de>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca> <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <1173955154.25356.28.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1173955154.25356.28.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ashif Harji <asharji@cs.uwaterloo.ca>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 11:39:14AM +0100, Peter Zijlstra wrote:
> On Wed, 2007-03-14 at 15:58 -0400, Ashif Harji wrote:
> > This patch unconditionally calls mark_page_accessed to prevent pages, 
> > especially for small files, from being evicted from the page cache despite 
> > frequent access.
> 
> Since we're hackling over the use-once stuff again...
> 
> /me brings up: http://marc.info/?l=linux-mm&m=115316894804385&w=2 and
> ducks.

Join the club ;) 

http://groups.google.com.au/group/linux.kernel/msg/7b3237b8e715475b?hl=en&

I can't find the patch where I actually did combine it with a PG_usedonce
bit, but the end result is pretty similar to your patch. And I think one
or two others have also independently invented the same thing.

So it *has* to be good, doesn't it? ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
