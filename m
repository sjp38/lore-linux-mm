Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC7906B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 17:36:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u21-v6so1484250pfn.0
        for <linux-mm@kvack.org>; Thu, 31 May 2018 14:36:46 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b67-v6si37440929pfa.71.2018.05.31.14.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 14:36:45 -0700 (PDT)
Date: Thu, 31 May 2018 15:36:43 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v11 00/63] Convert page cache to XArray
Message-ID: <20180531213643.GD28256@linux.intel.com>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180416160133.GA12434@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180416160133.GA12434@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Mon, Apr 16, 2018 at 10:01:33AM -0600, Ross Zwisler wrote:
> On Sat, Apr 14, 2018 at 07:12:13AM -0700, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > This conversion keeps the radix tree and XArray data structures in sync
> > at all times.  That allows us to convert the page cache one function at
> > a time and should allow for easier bisection.  Other than renaming some
> > elements of the structures, the data structures are fundamentally
> > unchanged; a radix tree walk and an XArray walk will touch the same
> > number of cachelines.  I have changes planned to the XArray data
> > structure, but those will happen in future patches.
> 
> I've hit a few failures when throwing this into my test setup.  The first two
> seem like similar bugs hit in two different ways, the third seems unique.
> I've verified that these don't seem to happen with the next-20180413 baseline.

Hey Matthew, did you ever figure out these failures?
