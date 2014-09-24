Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id AE02D6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 22:06:07 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id id10so5087623vcb.0
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:06:07 -0700 (PDT)
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
        by mx.google.com with ESMTPS id fh1si5141729vcb.46.2014.09.23.19.06.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 19:06:07 -0700 (PDT)
Received: by mail-vc0-f181.google.com with SMTP id ik5so4812173vcb.26
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:06:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140924012422.4838.29188.stgit@notabene.brown>
References: <20140924012422.4838.29188.stgit@notabene.brown>
Date: Tue, 23 Sep 2014 22:06:06 -0400
Message-ID: <CAHQdGtRrU+vKB9s=Yks0rB0nVFy1-wOuW94ZrLsjMqGyLib=kQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] Remove possible deadlocks in nfs_release_page() - V3
From: Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Linux Kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Devel FS Linux <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Sep 23, 2014 at 9:28 PM, NeilBrown <neilb@suse.de> wrote:
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

Thanks Neil! I'll give them a final review tomorrow, and then queue
them up for the 3.18 merge window.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
