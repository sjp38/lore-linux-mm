Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 144906B05F8
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:48:36 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d9-v6so5389500plj.4
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:48:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c12-v6si7903344plr.467.2018.05.18.09.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:48:34 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: buffered I/O without buffer heads in xfs and iomap v2
Date: Fri, 18 May 2018 18:47:56 +0200
Message-Id: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Hi all,

this series adds support for buffered I/O without buffer heads to
the iomap and XFS code.

For now this series only contains support for block size == PAGE_SIZE,
with the 4k support split into a separate series.


A git tree is available at:

    git://git.infradead.org/users/hch/xfs.git xfs-iomap-read.2

Gitweb:

    http://git.infradead.org/users/hch/xfs.git/shortlog/refs/heads/xfs-iomap-read.2

Changes since v1:
 - fix the iomap_readpages error handling
 - use unsigned file offsets in a few places to avoid arithmetic overflows
 - allocate a iomap_page in iomap_page_mkwrite to fix generic/095
 - improve a few comments
 - add more asserts
 - warn about truncated block numbers from ->bmap
 - new patch to change the __do_page_cache_readahead return value to
   unsigned int
 - remove an incorrectly added empty line
 - make inline data an explicit iomap type instead of a flag
 - add a IOMAP_F_BUFFER_HEAD flag to force use of buffers heads for gfs2,
   and keep the basic buffer head infrastructure around for now.
