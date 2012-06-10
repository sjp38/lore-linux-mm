Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 1E9FD6B005C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 06:50:02 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so3841564bkc.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 03:50:00 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 00/10] minor frontswap cleanups and tracing support
Date: Sun, 10 Jun 2012 12:50:58 +0200
Message-Id: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Most of these patches are minor cleanups to the mm/frontswap.c code, the big
chunk of new code can be attributed to the new tracing support.

Changes in v3:
 - Fix merge error
 - Commenct about new spinlock assertions

Changes in v2:
 - Rebase to current version
 - Address Konrad's comments

Sasha Levin (10):
  mm: frontswap: remove casting from function calls through ops
    structure
  mm: frontswap: trivial coding convention issues
  mm: frontswap: split out __frontswap_curr_pages
  mm: frontswap: split out __frontswap_unuse_pages
  mm: frontswap: split frontswap_shrink further to simplify locking
  mm: frontswap: make all branches of if statement in put page
    consistent
  mm: frontswap: remove unnecessary check during initialization
  mm: frontswap: add tracing support
  mm: frontswap: split out function to clear a page out
  mm: frontswap: remove unneeded headers

 include/trace/events/frontswap.h |  167 ++++++++++++++++++++++++++++++++++++++
 mm/frontswap.c                   |  162 +++++++++++++++++++++++-------------
 2 files changed, 270 insertions(+), 59 deletions(-)
 create mode 100644 include/trace/events/frontswap.h

-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
