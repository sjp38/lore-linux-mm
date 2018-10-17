Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF1E6B026A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:28:17 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 134-v6so1107720pga.1
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:28:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y5-v6si15997720pgv.38.2018.10.17.01.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:28:16 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:28:14 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 10/26] vfs: combine the clone and dedupe into a single
 remap_file_range
Message-ID: <20181017082814.GB16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153965946503.1256.14921970220584184352.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153965946503.1256.14921970220584184352.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

> +/* All valid REMAP_FILE flags */
> +#define REMAP_FILE_VALID_FLAGS		(REMAP_FILE_DEDUP)

It looks like this still isn't used after the whole series.

With it removed:

Reviewed-by: Christoph Hellwig <hch@lst.de>
