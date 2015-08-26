Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 940606B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 14:32:57 -0400 (EDT)
Received: by qgeh99 with SMTP id h99so72367724qge.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:32:57 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id m75si23625836qki.120.2015.08.26.11.32.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 11:32:56 -0700 (PDT)
Received: by qgeh99 with SMTP id h99so72367390qge.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:32:56 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 0/2] zswap: use charp type params instead of fixed-len strings
Date: Wed, 26 Aug 2015 14:32:48 -0400
Message-Id: <1440613970-23913-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dan Streetman <ddstreet@ieee.org>

These patches change zswap to use charp type params instead of the
existing fixed length char[] buffers for the zpool and compressor params.
This saves memory and simplifies the param setting function.

Dan Streetman (2):
  module: export param_free_charp()
  zswap: use charp for zswap param strings

 include/linux/moduleparam.h |  1 +
 kernel/params.c             |  3 +-
 mm/zswap.c                  | 80 ++++++++++++++++++++++-----------------------
 3 files changed, 43 insertions(+), 41 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
