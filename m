Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA9BC6B0007
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:31:26 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b31-v6so13899895plb.5
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 04:31:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x1-v6si714216plb.8.2018.06.12.04.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Jun 2018 04:31:25 -0700 (PDT)
Date: Tue, 12 Jun 2018 04:31:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v13 00/72] Convert page cache to XArray
Message-ID: <20180612113122.GA19433@bombadil.infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
 <20180612104041.GB24375@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180612104041.GB24375@twin.jikos.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dsterba@suse.cz, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Tue, Jun 12, 2018 at 12:40:41PM +0200, David Sterba wrote:
> [ 9875.174796] kernel BUG at fs/inode.c:513!

What the ...

Somehow the fix for that got dropped.  I spent most of last week chasing
that problem!  This is the correct code:

http://git.infradead.org/users/willy/linux-dax.git/commitdiff/01177bb06761539af8a6c872416109e2c8b64559

I'll check over the patchset and see if anything else got dropped!
