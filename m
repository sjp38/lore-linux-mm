Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A04F9280411
	for <linux-mm@kvack.org>; Tue,  9 May 2017 08:18:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z88so19475988wrc.9
        for <linux-mm@kvack.org>; Tue, 09 May 2017 05:18:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 25si19255331wrw.297.2017.05.09.05.18.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 05:18:57 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/4 v3] mm,dax: Fix data corruption due to mmap inconsistency
Date: Tue,  9 May 2017 14:18:33 +0200
Message-Id: <20170509121837.26153-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Hello,

this series fixes data corruption that can happen for DAX mounts when
page faults race with write(2) and as a result page tables get out of sync
with block mappings in the filesystem and thus data seen through mmap is
different from data seen through read(2).

The series passes testing with t_mmap_stale test program from Ross and also
other mmap related tests on DAX filesystem.

Andrew, can you please merge these patches? Thanks!

Changes since v2:
* Added reviewed-by tag from Ross

Changes since v1:
* Improved performance of unmapping pages
* Changed fault locking to fix another write vs fault race

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
