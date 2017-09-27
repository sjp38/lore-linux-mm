Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87DE86B0274
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:04:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q75so23997812pfl.1
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:04:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x192si7941635pgx.381.2017.09.27.09.03.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 09:03:58 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/15 v2] Ranged pagevec tagged lookup
Date: Wed, 27 Sep 2017 18:03:19 +0200
Message-Id: <20170927160334.29513-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Hello,

This is second part of the split out of the larger series to clean up pagevec
APIs and provide ranged lookups. In this series I provide a ranged variant of
pagevec_lookup_tag() and use it in places where it makes sense. This series
removes some common code and it also has a potential for speeding up some
operations similarly as for pagevec_lookup_range() (but for now I can think
of only artificial cases where this happens).

The patches where filesystem changes are non-trivial got reviewed so I'm
confident enough that this can get merged. Andrew can you consider picking
these patches up please?

Full series including dependencies can be also obtained from my git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs.git find_get_pages_range

Opinions and review welcome!

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
