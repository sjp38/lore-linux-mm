Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFCE56B0003
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 15:59:02 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o2-v6so148164plk.0
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 12:59:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d11si5312124pgf.490.2018.04.14.12.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 12:59:01 -0700 (PDT)
Date: Sat, 14 Apr 2018 12:58:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v10 00/62] Convert page cache to XArray
Message-ID: <20180414195859.GC31523@bombadil.infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
 <a27d5689-49d9-2802-3819-afd0f1f98483@suse.com>
 <20180414195030.GB31523@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414195030.GB31523@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Sat, Apr 14, 2018 at 12:50:30PM -0700, Matthew Wilcox wrote:
> On Mon, Apr 09, 2018 at 04:18:07PM -0500, Goldwyn Rodrigues wrote:
> 
> I'm sorry I missed this email.  My inbox is a disaster :(
> 
> > I tried these patches against next-20180329 and added the patch for the
> > bug reported by Mike Kravetz. I am getting the following BUG on ext4 and
> > xfs, running generic/048 tests of fstests. Each trace is from a
> > different instance/run.
> 
> Yikes.  I haven't been able to reproduce this.  Maybe it's a matter of
> filesystem or some other quirk.
> 
> It seems easy for you to reproduce it, so would you mind bisecting it?
> Should be fairly straightforward; I'd start at commit "xarray: Add
> MAINTAINERS entry", since the page cache shouldn't be affected by anything
> up to that point, then bisect forwards from there.
> 
> > BTW, for my convenience, do you have these patches in a public git tree?
> 
> I didn't publish it; it's hard to push out a tree based on linux-next.
> I'll try to make that happen.

Figured it out:

http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-20180413

aka
 	git://git.infradead.org/users/willy/linux-dax.git xarray-20180413
