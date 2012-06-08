Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C52816B0071
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:14:38 -0400 (EDT)
Received: by yhr47 with SMTP id 47so2065223yhr.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 12:14:37 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 00/10] minor frontswap cleanups and tracing support
Date: Fri,  8 Jun 2012 21:15:09 +0200
Message-Id: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Most of these patches are minor cleanups to the mm/frontswap.c code, the big
chunk of new code can be attributed to the new tracing support.


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
