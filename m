Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58C9F6B0365
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:27:25 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id z22so59210327qtz.10
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:27:25 -0700 (PDT)
Received: from mail-qt0-f182.google.com (mail-qt0-f182.google.com. [209.85.216.182])
        by mx.google.com with ESMTPS id y3si11426743qta.82.2017.06.13.03.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 03:27:24 -0700 (PDT)
Received: by mail-qt0-f182.google.com with SMTP id u19so164910850qta.3
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:27:24 -0700 (PDT)
Message-ID: <1497349642.5762.3.camel@redhat.com>
Subject: Re: [PATCH v6 19/20] xfs: minimal conversion to errseq_t writeback
 error reporting
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 13 Jun 2017 06:27:22 -0400
In-Reply-To: <20170613043056.GO4530@birch.djwong.org>
References: <20170612122316.13244-1-jlayton@redhat.com>
	 <20170612122316.13244-24-jlayton@redhat.com>
	 <20170613043056.GO4530@birch.djwong.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Mon, 2017-06-12 at 21:30 -0700, Darrick J. Wong wrote:
> On Mon, Jun 12, 2017 at 08:23:15AM -0400, Jeff Layton wrote:
> > Just set the FS_WB_ERRSEQ flag to indicate that we want to use errseq_t
> > based error reporting. Internal filemap_* calls are left as-is for now.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/xfs/xfs_super.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> > index 455a575f101d..28d3be187025 100644
> > --- a/fs/xfs/xfs_super.c
> > +++ b/fs/xfs/xfs_super.c
> > @@ -1758,7 +1758,7 @@ static struct file_system_type xfs_fs_type = {
> >  	.name			= "xfs",
> >  	.mount			= xfs_fs_mount,
> >  	.kill_sb		= kill_block_super,
> > -	.fs_flags		= FS_REQUIRES_DEV,
> > +	.fs_flags		= FS_REQUIRES_DEV | FS_WB_ERRSEQ,
> 
> Huh?  Why are there two patches with the same subject line?  And this
> same bit of code too?  Or ... 11/13, 11/20?  What's going on here?
> 
> <confused>
> 
> --D

Oh my -- sorry about that. I ended up with two different interleaved
patchsets. The /20 series is the one I meant to send.

Just ignore these for now though, as I'll be sending a v7 (at least) to
address HCH's comments.
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
