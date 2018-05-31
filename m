Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF1806B0006
	for <linux-mm@kvack.org>; Thu, 31 May 2018 17:37:45 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c3-v6so12723912plz.7
        for <linux-mm@kvack.org>; Thu, 31 May 2018 14:37:45 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a21-v6si13847563pls.237.2018.05.31.14.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 14:37:44 -0700 (PDT)
Date: Thu, 31 May 2018 15:37:42 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v11 00/63] Convert page cache to XArray
Message-ID: <20180531213742.GE28256@linux.intel.com>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180416160133.GA12434@linux.intel.com>
 <20180531213643.GD28256@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180531213643.GD28256@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, May 31, 2018 at 03:36:43PM -0600, Ross Zwisler wrote:
> On Mon, Apr 16, 2018 at 10:01:33AM -0600, Ross Zwisler wrote:
> > On Sat, Apr 14, 2018 at 07:12:13AM -0700, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > This conversion keeps the radix tree and XArray data structures in sync
> > > at all times.  That allows us to convert the page cache one function at
> > > a time and should allow for easier bisection.  Other than renaming some
> > > elements of the structures, the data structures are fundamentally
> > > unchanged; a radix tree walk and an XArray walk will touch the same
> > > number of cachelines.  I have changes planned to the XArray data
> > > structure, but those will happen in future patches.
> > 
> > I've hit a few failures when throwing this into my test setup.  The first two
> > seem like similar bugs hit in two different ways, the third seems unique.
> > I've verified that these don't seem to happen with the next-20180413 baseline.
> 
> Hey Matthew, did you ever figure out these failures?

Never mind, just saw your mail from a few weeks ago.  :-/  I'll retest on my
end.
