Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3106B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 04:23:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l87so46011163qki.7
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 01:23:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q5si11210060qkq.255.2017.06.26.01.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 01:23:24 -0700 (PDT)
Date: Mon, 26 Jun 2017 10:23:15 +0200
From: Carlos Maiolino <cmaiolino@redhat.com>
Subject: Re: [PATCH v7 05/22] jbd2: don't clear and reset errors after
 waiting on writeback
Message-ID: <20170626082315.kun5momxqodrrm67@eorzea.usersys.redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
 <20170616193427.13955-6-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616193427.13955-6-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Fri, Jun 16, 2017 at 03:34:10PM -0400, Jeff Layton wrote:
> Resetting this flag is almost certainly racy, and will be problematic
> with some coming changes.
> 
> Make filemap_fdatawait_keep_errors return int, but not clear the flag(s).
> Have jbd2 call it instead of filemap_fdatawait and don't attempt to
> re-set the error flag if it fails.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/jbd2/commit.c   | 15 +++------------
>  include/linux/fs.h |  2 +-
>  mm/filemap.c       | 16 ++++++++++++++--
>  3 files changed, 18 insertions(+), 15 deletions(-)
> 
I'm not too experienced with jbd2 internals, but this patch is clear enough:

Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>

-- 
Carlos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
