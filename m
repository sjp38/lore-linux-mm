Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D36E96B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:09 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/10] Fix page_mkwrite() for blocksize < pagesize (version 3)
Date: Mon, 15 Jun 2009 19:59:47 +0200
Message-Id: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>


patches below are an attempt to solve problems filesystems have with
page_mkwrite() when blocksize < pagesize (see the changelog of the second patch
for details).

Could someone please review them so that they can get merged - especially the
generic VFS/MM part? It fixes observed problems (WARN_ON triggers) for ext4 and
makes ext2/ext3 behave more nicely (mmapped write getting page fault instead
of silently discarding data).

The series is against Linus's tree from today. The differences against previous
version are one bugfix in ext3 delalloc implementation... Please test and review.
Thanks.

									Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
