Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D60F6B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 18:31:18 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p59MVGnW014197
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 15:31:16 -0700
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by hpaq2.eem.corp.google.com with ESMTP id p59MUZmP030984
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 15:31:04 -0700
Received: by pwi4 with SMTP id 4so1264104pwi.11
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 15:31:04 -0700 (PDT)
Date: Thu, 9 Jun 2011 15:30:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/7] tmpfs: simplify by splice instead of readpage
Message-ID: <alpine.LSU.2.00.1106091529060.2200@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here's a second patchset for mmotm, based on 30-rc2 plus the 14
in mm tmpfs and trunc changes, which were preparation for this.

Add shmem_file_splice_read(), remove shmem_readpage(), and
simplify: before advancing to the interesting radix_tree
conversion in the final patchset, to follow in a few days.

1/7 tmpfs: clone shmem_file_splice_read
2/7 tmpfs: refine shmem_file_splice_read
3/7 tmpfs: pass gfp to shmem_getpage_gfp
4/7 tmpfs: remove shmem_readpage
5/7 tmpfs: simplify prealloc_page
6/7 tmpfs: simplify filepage/swappage
7/7 tmpfs: simplify unuse and writepage

 fs/splice.c            |    4 
 include/linux/splice.h |    2 
 mm/shmem.c             |  549 ++++++++++++++++++++-------------------
 3 files changed, 299 insertions(+), 256 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
