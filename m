Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF4B96B025E
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:47:02 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y16so13145438wmd.6
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:47:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id op6si19384001wjc.85.2016.11.24.01.47.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Nov 2016 01:47:01 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/6 v2] dax: Page invalidation fixes
Date: Thu, 24 Nov 2016 10:46:30 +0100
Message-Id: <1479980796-26161-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>

Hello,

this is second revision of my fixes of races when invalidating hole pages in
DAX mappings. See changelogs for details. The series is based on my patches to
write-protect DAX PTEs which are currently carried in mm tree. This is a hard
dependency because we really need to closely track dirtiness (and cleanness!)
of radix tree entries in DAX mappings in order to avoid discarding valid dirty
bits leading to missed cache flushes on fsync(2).

The tests have passed xfstests for xfs and ext4 in DAX and non-DAX mode.

I'd like to get some review of the patches (MM/FS people, please check whether
you like the direction changes in mm/truncate.c take in patch 2/6 - added
Johannes to CC since he was touching related code recently) so that these
patches can land in some tree once DAX write-protection patches are merged.
I'm hoping to get at least first three patches merged for 4.10-rc2... Thanks!

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
