Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id E40476B0088
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 18:30:00 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so13824716qcq.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 15:30:00 -0800 (PST)
Date: Thu, 29 Nov 2012 15:29:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
In-Reply-To: <20121129145924.9fb05982.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1211291522550.3226@eggly.anvils>
References: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils> <20121129145924.9fb05982.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Zheng Liu <wenqing.lz@taobao.com>, Jeff liu <jeff.liu@oracle.com>, Jim Meyering <jim@meyering.net>, Paul Eggert <eggert@cs.ucla.edu>, Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Dave Chinner <david@fromorbit.com>, Marco Stornelli <marco.stornelli@gmail.com>, Chris Mason <chris.mason@fusionio.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 29 Nov 2012, Andrew Morton wrote:
> On Wed, 28 Nov 2012 17:22:03 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > +/*
> > + * llseek SEEK_DATA or SEEK_HOLE through the radix_tree.
> > + */
> > +static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
> > +				    pgoff_t index, pgoff_t end, int origin)
> 
> So I was starting at this wondering what on earth "origin" is and why
> it has the fishy-in-this-context type "int".
> 
> There is a pretty well established convention that the lseek seek mode
> is called "whence".
> 
> The below gets most of it.  Too anal?

No, not too anal: I'm all in favour of "whence", which is indeed
the name of that lseek argument - since mediaeval times I believe.

It's good to have words like that in the kernel source: while you're
in the mood, please see if you can find good homes for "whither" and
"thrice" and "widdershins".

Thanks!
Hugh

> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: lseek: the "whence" argument is called "whence"
> 
> But the kernel decided to call it "origin" instead.  Fix most of the
> sites.
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  fs/bad_inode.c           |    2 -
>  fs/block_dev.c           |    4 +--
>  fs/btrfs/file.c          |   16 +++++++-------
>  fs/ceph/dir.c            |    4 +--
>  fs/ceph/file.c           |    6 ++---
>  fs/cifs/cifsfs.c         |    8 +++----
>  fs/configfs/dir.c        |    4 +--
>  fs/ext3/dir.c            |    6 ++---
>  fs/ext4/dir.c            |    6 ++---
>  fs/ext4/file.c           |   22 ++++++++++----------
>  fs/fuse/file.c           |    8 +++----
>  fs/gfs2/file.c           |   10 ++++-----
>  fs/libfs.c               |    4 +--
>  fs/nfs/dir.c             |    6 ++---
>  fs/nfs/file.c            |   10 ++++-----
>  fs/ocfs2/extent_map.c    |   12 +++++------
>  fs/ocfs2/file.c          |    6 ++---
>  fs/pstore/inode.c        |    6 ++---
>  fs/read_write.c          |   40 ++++++++++++++++++-------------------
>  fs/seq_file.c            |    4 +--
>  fs/ubifs/dir.c           |    4 +--
>  include/linux/fs.h       |   12 +++++------
>  include/linux/ftrace.h   |    4 +--
>  include/linux/syscalls.h |    4 +--
>  kernel/trace/ftrace.c    |    4 +--
>  mm/shmem.c               |   20 +++++++++---------
>  26 files changed, 116 insertions(+), 116 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
