Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D22D6B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:02:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so180303128pfy.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:02:45 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id m5si49045434pgj.182.2016.12.13.12.02.43
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 12:02:44 -0800 (PST)
Date: Wed, 14 Dec 2016 07:01:57 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/6 v3] dax: Page invalidation fixes
Message-ID: <20161213200157.GA4326@dastard>
References: <20161212164708.23244-1-jack@suse.cz>
 <20161213115209.GG15362@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161213115209.GG15362@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org

On Tue, Dec 13, 2016 at 12:52:09PM +0100, Jan Kara wrote:
> On Mon 12-12-16 17:47:02, Jan Kara wrote:
> > Hello,
> > 
> > this is the third revision of my fixes of races when invalidating hole pages in
> > DAX mappings. See changelogs for details. The series is based on my patches to
> > write-protect DAX PTEs which are currently carried in mm tree. This is a hard
> > dependency because we really need to closely track dirtiness (and cleanness!)
> > of radix tree entries in DAX mappings in order to avoid discarding valid dirty
> > bits leading to missed cache flushes on fsync(2).
> > 
> > The tests have passed xfstests for xfs and ext4 in DAX and non-DAX mode.
> > 
> > Johannes, are you OK with patch 2/6 in its current form? I'd like to push these
> > patches to some tree once DAX write-protection patches are merged.  I'm hoping
> > to get at least first three patches merged for 4.10-rc2... Thanks!
> 
> OK, with the final ack from Johannes and since this is mostly DAX stuff,
> can we take this through NVDIMM tree and push to Linus either late in the
> merge window or for -rc2? These patches require my DAX patches sitting in mm
> tree so they can be included in any git tree only once those patches land
> in Linus' tree (which may happen only once Dave and Ted push out their
> stuff - this is the most convoluted merge window I'd ever to deal with ;-)...

And I'm waiting on Jens and the block tree before I send Linus
a pulllreq for all the stuff I have queued because of the conflicts
in the iomap-direct IO patches I've also got in the XFS tree... :/

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
