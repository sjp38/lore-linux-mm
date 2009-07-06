Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F260E6B0055
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 12:45:43 -0400 (EDT)
Date: Mon, 6 Jul 2009 13:23:45 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 2/3] fs: make use of new helper functions
Message-ID: <20090706172345.GB26042@infradead.org>
References: <20090706165438.GQ2714@wotan.suse.de> <20090706165522.GR2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090706165522.GR2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 06, 2009 at 06:55:22PM +0200, Nick Piggin wrote:
> 
> Update some fs code to make use of new helper functions introduced
> in the previous patch. Should be no significant change in behaviour
> (except CIFS now calls send_sig under i_lock, via inode_truncate_ok).
> 
> ---
>  fs/buffer.c           |   10 +--------
>  fs/cifs/inode.c       |   51 ++++++++-----------------------------------------
>  fs/fuse/dir.c         |   13 +++---------
>  fs/fuse/fuse_i.h      |    2 -
>  fs/fuse/inode.c       |   10 ---------
>  fs/nfs/inode.c        |   52 +++++++++++---------------------------------------
>  fs/ramfs/file-nommu.c |   18 ++++-------------
>  7 files changed, 33 insertions(+), 123 deletions(-)

Nice cleanup.  I would recommend moving the introduction of those
helpers to this patch and make it the first in the series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
