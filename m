From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16978.46735.644387.570159@gargle.gargle.HOWL>
Date: Tue, 5 Apr 2005 20:02:23 +0400
Subject: "orphaned pagecache memleak fix" question.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <Andrea@Suse.DE>
Cc: linux-mm@kvack.org, Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

Hello,

I have few question about recent "orphaned pagecache memleak fix"
change-set:

 - how is it supposed to work with file systems that use page->private
 (and PG_private) for something else than buffer head ring? Such file
 systems may leak truncated pages for precisely the same reasons
 reiserfs does, and try_to_free_buffers(page) will most likely oops;

 - as I see it, nr_dirty shouldn't be updated after calling
 ClearPageDirty() because page->mapping was NULL already at the time of
 corresponding __set_page_dirty_nobuffers() call. Right?

 - wouldn't it be simpler to unconditionally remove page from LRU in
 ->invalidatepage()?

Nikita.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
