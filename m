Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99E696B0005
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 08:07:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u21-v6so6015829pfn.0
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 05:07:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t8-v6si8519734pgq.369.2018.06.16.05.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 05:07:31 -0700 (PDT)
Date: Sat, 16 Jun 2018 05:07:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v13 00/72] Convert page cache to XArray
Message-ID: <20180616120721.GA15447@bombadil.infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
 <20180612104041.GB24375@twin.jikos.cz>
 <20180612113122.GA19433@bombadil.infradead.org>
 <20180612193741.GC28436@linux.intel.com>
 <20180612194619.GH19433@bombadil.infradead.org>
 <20180613201021.GA4801@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180613201021.GA4801@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, dsterba@suse.cz, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Wed, Jun 13, 2018 at 02:10:21PM -0600, Ross Zwisler wrote:
> I tested xarray-20180612 vs next-20180612, and your patches cause a new
> deadlock with XFS + DAX + generic/269.  Here's the output from
> "echo w > /proc/sysrq-trigger":

After getting my pmem setup working (thanks for the help Dan &
Jeff), I tracked this down to a missing call to dax_wake_entry() in
dax_writeback_one().  I'm running xfstests -g auto now to see if
there's anything else that needs to be fixed.
