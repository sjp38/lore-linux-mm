Message-ID: <3D73B7F1.2EB3131E@zip.com.au>
Date: Mon, 02 Sep 2002 12:11:45 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
References: <20020902194345.A30976@lst.de> <3D73B2F9.FB1E7968@zip.com.au> <20020902204138.A31717@lst.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> 
> On Mon, Sep 02, 2002 at 11:50:33AM -0700, Andrew Morton wrote:
> > Christoph Hellwig wrote:
> > >
> > > This patch was done after Linus requested it when I intended to split
> > > madvice out of filemap.c.  We extend splitvma() in mmap.c to take
> > > another argument that specifies whether to split above or below the
> > > address given, and thus can use it in those function, cleaning them up
> > > a lot and removing most of their code.
> > >
> >
> > This description seems to have leaked from a different patch.
> >
> > Your patch purely shuffles code about, yes?
> 
> No.  it makes madvise/mlock/mprotect use slit_vma (that involved from
> splitvma).  There is no change in behaviour (verified by ltp testruns),
> but the implementation is very different, and lots of code is gone.

did you send the right patch?

mnm:/usr/src/25> grep split patches/madvise-move.patch 
- * We can potentially split a vm area into separate
+ * We can potentially split a vm area into separate

mnm:/usr/src/25> diffstat patches/madvise-move.patch
 Makefile  |    2 
 filemap.c |  332 ------------------------------------------------------------
 madvise.c |  340 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 342 insertions(+), 332 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
