Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 860DA6B0253
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:47:23 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so15370918wma.2
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 08:47:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qq8si45072281wjc.143.2016.12.12.08.47.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 08:47:22 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/6 v3] dax: Page invalidation fixes
Date: Mon, 12 Dec 2016 17:47:02 +0100
Message-Id: <20161212164708.23244-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>

Hello,

this is the third revision of my fixes of races when invalidating hole pages in
DAX mappings. See changelogs for details. The series is based on my patches to
write-protect DAX PTEs which are currently carried in mm tree. This is a hard
dependency because we really need to closely track dirtiness (and cleanness!)
of radix tree entries in DAX mappings in order to avoid discarding valid dirty
bits leading to missed cache flushes on fsync(2).

The tests have passed xfstests for xfs and ext4 in DAX and non-DAX mode.

Johannes, are you OK with patch 2/6 in its current form? I'd like to push these
patches to some tree once DAX write-protection patches are merged.  I'm hoping
to get at least first three patches merged for 4.10-rc2... Thanks!

Changes since v2:
* Added Reviewed-by tags
* Fixed commit message of patch 3
* Slightly simplified dax_iomap_pmd_fault()
* Renamed truncation functions to express better what they do

Changes since v1:
* Rebased on top of patches in mm tree
* Added some Reviewed-by tags
* renamed some functions based on review feedback

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
