Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC786B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 09:46:56 -0400 (EDT)
Received: by qgj62 with SMTP id 62so4539255qgj.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:46:56 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id g11si5497543qhc.0.2015.08.05.06.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 06:46:56 -0700 (PDT)
Received: by qged69 with SMTP id d69so29831832qge.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:46:55 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 0/3] make zswap params changeable at runtime
Date: Wed,  5 Aug 2015 09:46:40 -0400
Message-Id: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

This is a resend of the patch series.  It makes creation of the zpool and
compressor dynamic, so that they can be changed at runtime.  This makes
using/configuring zswap easier, as before this zswap had to be configured
at boot time, using boot params.

This uses a single list to track both the zpool and compressor together,
although Seth had mentioned an alternative which is to track the zpools
and compressors using separate lists.  In the most common case, only a
single zpool and single compressor, using one list is slightly simpler
than using two lists, and for the uncommon case of multiple zpools and/or
compressors, using one list is slightly less simple (and uses slightly
more memory, probably) than using two lists.

Dan Streetman (3):
  zpool: add zpool_has_pool()
  zswap: dynamic pool creation
  zswap: change zpool/compressor at runtime

 include/linux/zpool.h |   2 +
 mm/zpool.c            |  25 ++
 mm/zswap.c            | 683 ++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 555 insertions(+), 155 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
