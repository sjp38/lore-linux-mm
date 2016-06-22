Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E40EE828E2
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 09:12:57 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so35793617lfe.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 06:12:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8si743309wmc.18.2016.06.22.06.12.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 06:12:55 -0700 (PDT)
Date: Wed, 22 Jun 2016 15:12:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v8 0/2] improve sync efficiency with sb inode wb list
Message-ID: <20160622131249.GE16492@quack2.suse.cz>
References: <1466594593-6757-1-git-send-email-bfoster@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466594593-6757-1-git-send-email-bfoster@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>, Josef Bacik <jbacik@fb.com>, Jan Kara <jack@suse.cz>, Holger Hoffstatte <holger@applied-asynchrony.com>

On Wed 22-06-16 07:23:11, Brian Foster wrote:
> This is just a rebase to linus' latest master. I haven't heard any
> feedback on this one so Jan suggested I send to a wider audience.

Yeah. Brian is sending these patches for a few months and they get ignored.
Andrew, can you please pick them up if Al doesn't? Thanks!

								Honza

> v8:
> - Rebased to latest master.
> - Added Holger's Tested-by.
> v7: http://marc.info/?l=linux-fsdevel&m=145349651407631&w=2
> - Updated patch 1/2 commit log description to reference performance
>   impact.
> v6: http://marc.info/?l=linux-fsdevel&m=145322635828644&w=2
> - Use rcu locking instead of s_inode_list_lock spinlock in
>   wait_sb_inodes().
> - Refactor wait_sb_inodes() to keep inode on wb list.
> - Drop remaining, unnecessary lazy list removal bits and relocate inode
>   list check to clear_inode().
> - Fix up some comments, etc.
> v5: http://marc.info/?l=linux-fsdevel&m=145262374402798&w=2
> - Converted from per-bdi list to per-sb list. Also marked as RFC and
>   dropped testing/review tags.
> - Updated to use new irq-safe lock for wb list.
> - Dropped lazy list removal. Inodes are removed when the mapping is
>   cleared of the writeback tag.
> - Tweaked wait_sb_inodes() to remove deferred iput(), other cleanups.
> - Added wb list tracepoint patch.
> v4: http://marc.info/?l=linux-fsdevel&m=143511628828000&w=2
> 
> Brian Foster (1):
>   wb: inode writeback list tracking tracepoints
> 
> Dave Chinner (1):
>   sb: add a new writeback list for sync
> 
>  fs/fs-writeback.c                | 111 ++++++++++++++++++++++++++++++---------
>  fs/inode.c                       |   2 +
>  fs/super.c                       |   2 +
>  include/linux/fs.h               |   4 ++
>  include/linux/writeback.h        |   3 ++
>  include/trace/events/writeback.h |  22 ++++++--
>  mm/page-writeback.c              |  18 +++++++
>  7 files changed, 133 insertions(+), 29 deletions(-)
> 
> -- 
> 2.5.5
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
