Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 95DC26B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 22:10:42 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so76642973pad.10
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 19:10:42 -0800 (PST)
Received: from fiona.linuxhacker.ru ([217.76.32.60])
        by mx.google.com with ESMTPS id gq5si22041838pac.127.2015.02.01.19.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Feb 2015 19:10:41 -0800 (PST)
From: green@linuxhacker.ru
Subject: [PATCH 0/2] Export __vmalloc_node symbol
Date: Sun,  1 Feb 2015 22:10:25 -0500
Message-Id: <1422846627-26890-1-git-send-email-green@linuxhacker.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Looking to get rid of a deadlock in Lustre where vmalloc call recurses
right back into Lustre to free some memory due to not accepting GFP mask
I noticed that while vzalloc is replaceable with __vmalloc just as
suggested, vzalloc_node is not. Recommended __vmalloc_node symbol is
static to mm/vmalloc.c.
Hopefully nobody has any objections to me exporting it so that
vzalloc_node suggestion actually becomes possible.

Second patch in the series is just a Lustre patch to take advantage
of that newly exported symbol (as an example of usage).

Please consider.

Bruno Faccini (1):
  staging/lustre: use __vmalloc_node() to avoid __GFP_FS default

Oleg Drokin (1):
  mm: Export __vmalloc_node

 drivers/staging/lustre/lustre/include/obd_support.h | 18 ++++++++++++------
 include/linux/vmalloc.h                             |  3 +++
 mm/vmalloc.c                                        | 10 ++++------
 3 files changed, 19 insertions(+), 12 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
