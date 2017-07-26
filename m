Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65BC86B03B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g71so10491269wmg.13
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si13666893wrb.436.2017.07.26.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:27 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/10 v2] Ranged pagevec lookup
Date: Wed, 26 Jul 2017 13:46:54 +0200
Message-Id: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, linux-fsdevel@vger.kernel.org

Hello,

This patch series was split out of the larger series to clean up pagevec APIs
and provide ranged lookups. In this series I make pagevec_lookup() update the
index (to be consistent with pagevec_lookup_tag() and also as a preparation
for ranged lookups), provide ranged variant of pagevec_lookup() and use it
in places where it makes sense. This not only removes some common code but
is also a measurable performance win for some use cases (see patch 4/10) where
radix tree is sparse and searching & grabing of a page after the end of the
range has measurable overhead.

Andrew, can you please consider merging this series?

Full series including dependencies can be also obtained from my git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs.git find_get_pages_range

Opinions and review welcome!

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
