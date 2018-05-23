Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A42386B0010
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:46:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q22-v6so5900760pgv.22
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:46:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e63-v6si18842099pfd.261.2018.05.23.07.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:46:50 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: sub-page blocksize support in iomap non-buffer head path v3
Date: Wed, 23 May 2018 16:46:44 +0200
Message-Id: <20180523144646.19159-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Hi all,

this series adds support for buffered I/O without buffer heads for
block size < PAGE_SIZE to the iomap and XFS code.

A git tree is available at:

    git://git.infradead.org/users/hch/xfs.git xfs-iomap-read xfs-remove-bufferheads.2

Gitweb:

    http://git.infradead.org/users/hch/xfs.git/shortlog/refs/heads/xfs-remove-bufferheads.2

Changes since v2:
 - rebased

Changes since v1:
 - call iomap_page_create in page_mkwrite to fix generic/095
 - split into a separate series
