Date: Mon, 2 Sep 2002 20:41:38 +0200
From: Christoph Hellwig <hch@lst.de>
Message-ID: <20020902204138.A31717@lst.de>
References: <20020902194345.A30976@lst.de> <3D73B2F9.FB1E7968@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D73B2F9.FB1E7968@zip.com.au>; from akpm@zip.com.au on Mon, Sep 02, 2002 at 11:50:33AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2002 at 11:50:33AM -0700, Andrew Morton wrote:
> Christoph Hellwig wrote:
> > 
> > This patch was done after Linus requested it when I intended to split
> > madvice out of filemap.c.  We extend splitvma() in mmap.c to take
> > another argument that specifies whether to split above or below the
> > address given, and thus can use it in those function, cleaning them up
> > a lot and removing most of their code.
> > 
> 
> This description seems to have leaked from a different patch.
> 
> Your patch purely shuffles code about, yes?

No.  it makes madvise/mlock/mprotect use slit_vma (that involved from
splitvma).  There is no change in behaviour (verified by ltp testruns),
but the implementation is very different, and lots of code is gone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
