Message-ID: <3D73B2F9.FB1E7968@zip.com.au>
Date: Mon, 02 Sep 2002 11:50:33 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
References: <20020902194345.A30976@lst.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> 
> This patch was done after Linus requested it when I intended to split
> madvice out of filemap.c.  We extend splitvma() in mmap.c to take
> another argument that specifies whether to split above or below the
> address given, and thus can use it in those function, cleaning them up
> a lot and removing most of their code.
> 

This description seems to have leaked from a different patch.

Your patch purely shuffles code about, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
