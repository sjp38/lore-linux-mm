Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2C836B025E
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 17:46:30 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b21so526410qte.20
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 14:46:30 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 37si4516800qkz.546.2017.09.29.14.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 14:46:30 -0700 (PDT)
Subject: Re: [PATCH 14/15] mm: Remove nr_pages argument from
 pagevec_lookup_{,range}_tag()
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-15-jack@suse.cz>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <d86aeb9d-fc2b-c041-ae24-d8ccf06325e7@oracle.com>
Date: Fri, 29 Sep 2017 17:46:24 -0400
MIME-Version: 1.0
In-Reply-To: <20170927160334.29513-15-jack@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 09/27/2017 12:03 PM, Jan Kara wrote:
> All users of pagevec_lookup() and pagevec_lookup_range() now pass
> PAGEVEC_SIZE as a desired number of pages. Just drop the argument.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>   fs/btrfs/extent_io.c    | 6 +++---

There's one place that got missed in fs/ceph/addr.c:

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 87789c477381..ee68b3db6729 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1161,8 +1161,7 @@ static int ceph_writepages_start(struct 
address_space *mapping,
                         index = 0;
                         while ((index <= end) &&
                                (nr = pagevec_lookup_tag(&pvec, mapping, 
&index,
- PAGECACHE_TAG_WRITEBACK,
- PAGEVEC_SIZE))) {
+ PAGECACHE_TAG_WRITEBACK))) {
                                 for (i = 0; i < nr; i++) {
                                         page = pvec.pages[i];
                                         if (page_snap_context(page) != 
snapc)


Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
