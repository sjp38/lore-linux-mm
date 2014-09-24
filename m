Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id D0B896B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 07:27:04 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id o8so3222975qcw.6
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 04:27:04 -0700 (PDT)
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
        by mx.google.com with ESMTPS id n1si6758960qai.103.2014.09.24.04.27.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 04:27:04 -0700 (PDT)
Received: by mail-qg0-f48.google.com with SMTP id z107so5618319qgd.7
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 04:27:03 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 24 Sep 2014 07:27:01 -0400
Subject: Re: [PATCH 0/5]  Remove possible deadlocks in nfs_release_page() -
 V3
Message-ID: <20140924072701.49a70346@tlielax.poochiereds.net>
In-Reply-To: <20140924012422.4838.29188.stgit@notabene.brown>
References: <20140924012422.4838.29188.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 24 Sep 2014 11:28:32 +1000
NeilBrown <neilb@suse.de> wrote:

> This set includes acked-by's from Andrew and Peter so it should be
> OK for all five patches to go upstream through the NFS tree.
> 
> I split the congestion tracking patch out from the wait-for-PG_private
> patch as they are conceptually separate.
> 
> This set continues to perform well in my tests and addresses all
> issues that have been raised.
> 
> Thanks a lot,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (5):
>       SCHED: add some "wait..on_bit...timeout()" interfaces.
>       MM: export page_wakeup functions
>       NFS: avoid deadlocks with loop-back mounted NFS filesystems.
>       NFS: avoid waiting at all in nfs_release_page when congested.
>       NFS/SUNRPC: Remove other deadlock-avoidance mechanisms in nfs_release_page()
> 
> 
>  fs/nfs/file.c                   |   29 +++++++++++++++++++----------
>  fs/nfs/write.c                  |    7 +++++++
>  include/linux/pagemap.h         |   12 ++++++++++--
>  include/linux/wait.h            |    5 ++++-
>  kernel/sched/wait.c             |   36 ++++++++++++++++++++++++++++++++++++
>  mm/filemap.c                    |   21 +++++++++++++++------
>  net/sunrpc/sched.c              |    2 --
>  net/sunrpc/xprtrdma/transport.c |    2 --
>  net/sunrpc/xprtsock.c           |   10 ----------
>  9 files changed, 91 insertions(+), 33 deletions(-)
> 

Cool!

This looks like it'll address my earlier concern about setting the BDI
congested inappropriately. You can add this to the set if you like:

Acked-by: Jeff Layton <jlayton@primarydata.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
