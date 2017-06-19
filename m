Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFD556B03BC
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:12:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so4043975wrz.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:12:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si9501852wro.213.2017.06.19.06.12.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Jun 2017 06:12:55 -0700 (PDT)
Date: Mon, 19 Jun 2017 15:12:53 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/35] fscache: Remove unused ->now_uncached callback
Message-ID: <20170619131253.GA22128@quack2.suse.cz>
References: <20170601093245.29238-2-jack@suse.cz>
 <20170601093245.29238-1-jack@suse.cz>
 <10376.1496312768@warthog.procyon.org.uk>
 <20170601113434.GC23077@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601113434.GC23077@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>

On Thu 01-06-17 13:34:34, Jan Kara wrote:
> On Thu 01-06-17 11:26:08, David Howells wrote:
> > Jan Kara <jack@suse.cz> wrote:
> > 
> > > The callback doesn't ever get called. Remove it.
> > 
> > Hmmm...  I should perhaps be calling this.  I'm not sure why I never did.
> > 
> > At the moment, it doesn't strictly matter as ops on pages marked with
> > PG_fscache get ignored if the cache has suffered an I/O error or has been
> > withdrawn - but it will incur a performance penalty (the PG_fscache flag is
> > checked in the netfs before calling into fscache).
> > 
> > The downside of calling this is that when a cache is removed, fscache would go
> > through all the cookies for that cache and iterate over all the pages
> > associated with those cookies - which could cause a performance dip in the
> > system.
> 
> So I know nothing about fscache. If you decide these functions should stay
> in as you are going to use them soon, then I can just convert them to the
> new API as everything else. What just caught my eye and why I had a more
> detailed look is that I didn't understand that 'PAGEVEC_SIZE -
> pagevec_count(&pvec)' as a pagevec_lookup() argument since pagevec_count()
> should always return 0 at that point?

David, what is your final decision regarding this? Do you want to keep
these unused functions (and I will just update my patch to convert them to
the new calling convention) or will you apply the patch to remove them?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
