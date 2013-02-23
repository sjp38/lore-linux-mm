Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 9E9896B0005
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 17:58:03 -0500 (EST)
From: Phillip Susi <psusi@ubuntu.com>
Subject: [PATCH 0/2] FADV_DONTNEED and FADV_NOREUSE
Date: Sat, 23 Feb 2013 17:57:59 -0500
Message-Id: <1361660281-22165-1-git-send-email-psusi@ubuntu.com>
In-Reply-To: <5127E8B7.9080202@ubuntu.com>
References: <5127E8B7.9080202@ubuntu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

How do the two of these look?

Phillip Susi (2):
  mm: fadvise: fix POSIX_FADV_DONTNEED
  mm: fadvise: implement POSIX_FADV_NOREUSE

 include/linux/fs.h |  5 +++++
 mm/fadvise.c       |  9 +++------
 mm/filemap.c       | 54 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 59 insertions(+), 9 deletions(-)

-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
