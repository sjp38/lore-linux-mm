Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D526D6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 04:05:32 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o8so10166120qtc.1
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 01:05:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p3si9181820qkd.63.2017.06.26.01.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 01:05:32 -0700 (PDT)
Date: Mon, 26 Jun 2017 10:05:26 +0200
From: Carlos Maiolino <cmaiolino@redhat.com>
Subject: Re: [PATCH v7 01/22] fs: remove call_fsync helper function
Message-ID: <20170626080526.ufetu6blf2kllihn@eorzea.usersys.redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
 <20170616193427.13955-2-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616193427.13955-2-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Fri, Jun 16, 2017 at 03:34:06PM -0400, Jeff Layton wrote:
> Requested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/sync.c          | 2 +-
>  include/linux/fs.h | 6 ------
>  ipc/shm.c          | 2 +-
>  3 files changed, 2 insertions(+), 8 deletions(-)
> 
> 2.13.0
If it's worth to have one more reviewer, you can add:

Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>

> 

-- 
Carlos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
