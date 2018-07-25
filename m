Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2986B6B0003
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 17:03:27 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c23-v6so1115949pfi.3
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 14:03:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o4-v6si14140241pgb.279.2018.07.25.14.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Jul 2018 14:03:25 -0700 (PDT)
Date: Wed, 25 Jul 2018 14:03:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v14 00/74] Convert page cache to XArray
Message-ID: <20180725210323.GB1366@bombadil.infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
 <20180619031257.GA12527@linux.intel.com>
 <20180619092230.GA1438@bombadil.infradead.org>
 <20180619164037.GA6679@linux.intel.com>
 <20180619171638.GE1438@bombadil.infradead.org>
 <20180627110529.GA19606@bombadil.infradead.org>
 <20180627194438.GA20774@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627194438.GA20774@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Wed, Jun 27, 2018 at 01:44:38PM -0600, Ross Zwisler wrote:
> On Wed, Jun 27, 2018 at 04:05:29AM -0700, Matthew Wilcox wrote:
> > On Tue, Jun 19, 2018 at 10:16:38AM -0700, Matthew Wilcox wrote:
> > > I think I see a bug.  No idea if it's the one you're hitting ;-)
> > > 
> > > I had been intending to not use the 'entry' to decide whether we were
> > > waiting on a 2MB or 4kB page, but rather the xas.  I shelved that idea,
> > > but not before dropping the DAX_PMD flag being passed from the PMD
> > > pagefault caller.  So if I put that back ...
> > 
> > Did you get a chance to test this?
> 
> With this patch it doesn't deadlock, but the test dies with a SIGBUS and we
> hit a WARN_ON in the DAX code:
> 
> WARNING: CPU: 5 PID: 1678 at fs/dax.c:226 get_unlocked_entry+0xf7/0x120
> 
> I don't have a lot of time this week to debug further.  The quickest path to
> victory is probably for you to get this reproducing in your test setup.  Does
> XFS + DAX + generic/340 pass for you?

I now have generic/340 passing.  I've pushed a new version to
git://git.infradead.org/users/willy/linux-dax.git xarray
