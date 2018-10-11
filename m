Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 223C76B0010
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:43:01 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f17-v6so6280822plr.1
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:43:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 16-v6si26410745pgw.208.2018.10.11.06.43.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Oct 2018 06:43:00 -0700 (PDT)
Date: Thu, 11 Oct 2018 06:42:56 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 03/25] vfs: check file ranges before cloning files
Message-ID: <20181011134256.GC23424@infradead.org>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923115968.5546.9927577186377570573.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153923115968.5546.9927577186377570573.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

> -EXPORT_SYMBOL(vfs_clone_file_prep_inodes);
> +EXPORT_SYMBOL(vfs_clone_file_prep);

Btw, why isn't this EXPORT_SYMBOL_GPL?  It is rather Linux internal
code, including some that I wrote which you lifted into the core
in "vfs: refactor clone/dedupe_file_range common functions".
