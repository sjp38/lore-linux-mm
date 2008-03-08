Received: by rv-out-0910.google.com with SMTP id f1so499544rvb.26
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 20:33:34 -0800 (PST)
Message-ID: <6934efce0803072033g3dab6106n32beb61532f365f7@mail.gmail.com>
Date: Fri, 7 Mar 2008 20:33:34 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: [RFC][PATCH 0/3] xip: no struct pages -- summary
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maxim Shchetynin <maxim@de.ibm.com>
List-ID: <linux-mm.kvack.org>

[RFC][PATCH 0/3] xip: no struct pages -- summary

This short series extendeds one of Nick Piggins patches for the XIP
overhaul that we've been kicking around.  I'm just hoping to get the
API changes reviewed now.  I haven't tested this, just compiled what I
can.

So what I'm doing here is swapping out get_xip_page() for
get_xip_mem().  The get_xip_mem() API gives us a kaddr and a pfn.  I
thought it worked best to force this kaddr and pfn down through the
block dev's direct_access() API.  I'm really unsure if I understand
whether I got the device specific implementations of the new
direct_access() right.

For those interested I'll be updating my git tree at
git.infradead.org/users/jehulber/axfs.git with an updated patch set
Monday.

[1/3] filemap_xip
fs/open.c          |    2
include/linux/fs.h |    4 -
mm/fadvise.c       |    2
mm/filemap_xip.c   |  204 ++++++++++++++++++++++++-----------------------------
mm/madvise.c       |    2
5 files changed, 101 insertions(+), 113 deletions(-)

[2/3] direct_access
arch/powerpc/sysdev/axonram.c |    5 +++--
drivers/block/brd.c           |    5 +++--
drivers/s390/block/dcssblk.c  |    7 +++++--
include/linux/fs.h            |    3 ++-
4 files changed, 13 insertions(+), 7 deletions(-)

[3/3] ext2
inode.c |    2 +-
xip.c   |   45 ++++++++++++++++++++++++---------------------
xip.h   |    9 +++++----
3 files changed, 30 insertions(+), 26 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
