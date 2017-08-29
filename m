Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93EA96B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 04:14:58 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d81so19785188ioj.10
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 01:14:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 1si2515949itp.34.2017.08.29.01.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 01:14:57 -0700 (PDT)
Date: Tue, 29 Aug 2017 01:14:53 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab
 cache
Message-ID: <20170829081453.GA10196@infradead.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503956111-36652-16-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

One thing I've been wondering is wether we should actually just
get rid of the online area.  Compared to reading an inode from
disk a single additional kmalloc is negligible, and not having the
inline data / extent list would allow us to reduce the inode size
significantly.

Kees/David:  how many of these patches are file systems with some
sort of inline data?  Given that it's only about 30 patches declaring
allocations either entirely valid for user copy or not might end up
being nicer in many ways than these offsets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
