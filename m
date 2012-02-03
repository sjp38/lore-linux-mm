Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 1CF626B002C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 12:28:27 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH] mm: Change of refcounting method for compound page.
Date: Fri,  3 Feb 2012 18:28:12 +0100
Message-Id: <1328290093-19294-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Yongqiang Yang <xiaoqiangnk@gmail.com>

Hello,

Currently, I try to enable huge pages for SHM (and generally for any page cache), during
this I ran into problem with ref-countig of huge pages.

Due to this I would like to propose patch for changing ref-counting for compound
page and allowing auto destruction of such page. I tried to revert behavior
from 2.6 kernels, and to make it concurrently safe, as well sophisticated
and compatible with THP.

I hope this removes risky way through call get_user_pages, too.

For me enabling such ref-counting is really important to continue work, and to
prevent huge changes in page cache managing.

Regards,
RadosA?aw Smogura (1):
  mm: Change of refcounting method for compound page.

 include/linux/mm.h       |   94 +++++++++++-----
 include/linux/mm_types.h |   24 ++++-
 include/linux/pagemap.h  |    1 -
 mm/huge_memory.c         |   30 ++---
 mm/internal.h            |   46 --------
 mm/memory.c              |    2 +-
 mm/page_alloc.c          |    2 +
 mm/swap.c                |  272 ++++++++++++++++++++++++++++++----------------
 8 files changed, 279 insertions(+), 192 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
