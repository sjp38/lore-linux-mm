Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id E31AB6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 18:36:06 -0400 (EDT)
Received: by ggm4 with SMTP id 4so13051462ggm.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 15:36:06 -0700 (PDT)
Date: Mon, 9 Jul 2012 15:35:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/3] shmem/tmpfs: three late patches
Message-ID: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Here's three little shmem/tmpfs patches against v3.5-rc6.
Either the first should go in before v3.5 final, or it should not go
in at all.  The second and third are independent of it: I'd like them
in v3.5, but don't have a clinching argument: see what you think.

[PATCH 1/3] tmpfs: revert SEEK_DATA and SEEK_HOLE
[PATCH 2/3] shmem: fix negative rss in memcg memory.stat
[PATCH 3/3] shmem: cleanup shmem_add_to_page_cache

 mm/shmem.c |  193 +++++++++++++++------------------------------------
 1 file changed, 58 insertions(+), 135 deletions(-)

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
