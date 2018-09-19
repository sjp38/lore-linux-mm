Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3017B8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 13:29:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v9-v6so3092061pff.4
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 10:29:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 144-v6sor2283895pgh.46.2018.09.19.10.29.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 10:29:21 -0700 (PDT)
Date: Wed, 19 Sep 2018 10:29:18 -0700
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v7 0/6] Btrfs: implement swap file support
Message-ID: <20180919172918.GI479@vader>
References: <cover.1536704650.git.osandov@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536704650.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>
Cc: kernel-team@fb.com, linux-mm@kvack.org

On Tue, Sep 11, 2018 at 03:34:43PM -0700, Omar Sandoval wrote:
> From: Omar Sandoval <osandov@fb.com>
> 
> Hi,
> 
> This series implements swap file support for Btrfs.
> 
> Changes from v6 [1]:
> 
> - Moved btrfs_get_chunk_map() comment to function body
> - Added more comments about pinned block group/device rbtree
> - Fixed bug in patch 4 which broke resize
> 
> Based on v4.19-rc3.
> 
> Thanks!
> 
> 1: https://www.spinics.net/lists/linux-btrfs/msg81732.html
> 
> Omar Sandoval (6):
>   mm: split SWP_FILE into SWP_ACTIVATED and SWP_FS
>   mm: export add_swap_extent()
>   vfs: update swap_{,de}activate documentation
>   Btrfs: prevent ioctls from interfering with a swap file
>   Btrfs: rename get_chunk_map() and make it non-static
>   Btrfs: support swap files
> 
>  Documentation/filesystems/Locking |  17 +-
>  Documentation/filesystems/vfs.txt |  12 +-
>  fs/btrfs/ctree.h                  |  29 +++
>  fs/btrfs/dev-replace.c            |   8 +
>  fs/btrfs/disk-io.c                |   4 +
>  fs/btrfs/inode.c                  | 317 ++++++++++++++++++++++++++++++
>  fs/btrfs/ioctl.c                  |  31 ++-
>  fs/btrfs/relocation.c             |  18 +-
>  fs/btrfs/volumes.c                |  82 ++++++--
>  fs/btrfs/volumes.h                |   2 +
>  include/linux/swap.h              |  13 +-
>  mm/page_io.c                      |   6 +-
>  mm/swapfile.c                     |  14 +-
>  13 files changed, 502 insertions(+), 51 deletions(-)

Ping, any other comments on this version?
