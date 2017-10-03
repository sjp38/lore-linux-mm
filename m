Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0866B6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 05:08:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k7so2908226wre.22
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 02:08:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si2463880wrd.437.2017.10.03.02.08.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 02:08:00 -0700 (PDT)
Date: Tue, 3 Oct 2017 11:07:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 14/15] mm: Remove nr_pages argument from
 pagevec_lookup_{,range}_tag()
Message-ID: <20171003090759.GH11879@quack2.suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-15-jack@suse.cz>
 <d86aeb9d-fc2b-c041-ae24-d8ccf06325e7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d86aeb9d-fc2b-c041-ae24-d8ccf06325e7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri 29-09-17 17:46:24, Daniel Jordan wrote:
> On 09/27/2017 12:03 PM, Jan Kara wrote:
> >All users of pagevec_lookup() and pagevec_lookup_range() now pass
> >PAGEVEC_SIZE as a desired number of pages. Just drop the argument.
> >
> >Signed-off-by: Jan Kara <jack@suse.cz>
> >---
> >  fs/btrfs/extent_io.c    | 6 +++---
> 
> There's one place that got missed in fs/ceph/addr.c:

Ah, that's probably from a rebase I did. Thanks for catching this!

								Honza

> 
> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> index 87789c477381..ee68b3db6729 100644
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
> @@ -1161,8 +1161,7 @@ static int ceph_writepages_start(struct address_space
> *mapping,
>                         index = 0;
>                         while ((index <= end) &&
>                                (nr = pagevec_lookup_tag(&pvec, mapping,
> &index,
> - PAGECACHE_TAG_WRITEBACK,
> - PAGEVEC_SIZE))) {
> + PAGECACHE_TAG_WRITEBACK))) {
>                                 for (i = 0; i < nr; i++) {
>                                         page = pvec.pages[i];
>                                         if (page_snap_context(page) !=
> snapc)
> 
> 
> Daniel
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
