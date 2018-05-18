Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8463B6B063E
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:52:12 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bd7-v6so5356395plb.20
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:52:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 43-v6si8116519plb.511.2018.05.18.09.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:52:11 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: sub-page blocksize support in iomap non-buffer head path
Date: Fri, 18 May 2018 18:52:04 +0200
Message-Id: <20180518165206.13829-1-hch@lst.de>
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

Changes since v1:
 - call iomap_page_create in page_mkwrite to fix generic/095
 - split into a separate series
