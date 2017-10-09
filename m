Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54A356B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:14:08 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a132so6436679lfa.17
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:14:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15si7426016wrc.417.2017.10.09.08.14.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 08:14:06 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/16 v3] Ranged pagevec tagged lookup
Date: Mon,  9 Oct 2017 17:13:43 +0200
Message-Id: <20171009151359.31984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Daniel Jordan <daniel.m.jordan@oracle.com>, Jan Kara <jack@suse.cz>

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

Changes since v2:
* style fixup in __filemap_fdatawait_range() suggested by Dave Chinner
* added couple of Reviewed-by tags
* fixed wrong EXPORT_SYMBOL spotted by Daniel Jordan
* added missed Ceph conversion spotted by Daniel Jordan
* added conversion of Cifs suggested by Daniel Jordan
* rebased on top of 4.14-rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
