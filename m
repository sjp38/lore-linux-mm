Subject: Re: kernel BUG at rmap.c:409! with 2.5.31 and akpm patches.
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3D61615C.451C2B44@zip.com.au>
References: <1029790457.14756.342.camel@spc9.esa.lanl.gov>
	<3D61615C.451C2B44@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 19 Aug 2002 16:04:48 -0600
Message-Id: <1029794688.14756.353.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Mon, 2002-08-19 at 15:21, Andrew Morton wrote:
> Steven Cole wrote:
> > 
> > Here's a new one.
> > 
> > With this patch applied to 2.5.31,
> > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.31/stuff-sent-to-linus/everything.gz
> > 
> > I got this BUG:
> > kernel BUG at rmap.c:409!
> > while running dbench 40 as a stress test.
> > 
> 
> OK, ext3's habit of leaving buffers attached to truncated pages
> seems to have tripped us up:
> 
> 	if (page->pte.chain && !page->mapping && !PagePrivate(page)) {
> 		...
> 	}
> 
> 	if (page->pte.chain) {
> 		switch (try_to_unmap(page)) {
> 
> So if the page has a pte_chain, and no ->mapping, but has buffers
> we go blam.

[patch snipped]

Patch applied, running dbench 1..128.  Up to 52 clients so far, and no
blam yet.  I'll run this test several times overnight and let you know
if anything else falls out.

Thanks,
Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
