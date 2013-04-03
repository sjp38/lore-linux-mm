Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 6D9F06B0027
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:42:49 -0400 (EDT)
Date: Wed, 3 Apr 2013 16:42:44 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3] mm: Make snapshotting pages for stable writes a
 per-bio operation
Message-ID: <20130403144244.GC14667@quack.suse.cz>
References: <20130313085021.GA29730@quack.suse.cz>
 <20130313194429.GE5313@blackbox.djwong.org>
 <20130313210216.GA7754@quack.suse.cz>
 <20130314224243.GI5313@blackbox.djwong.org>
 <20130315100105.GA4889@quack.suse.cz>
 <20130315232816.GN5313@blackbox.djwong.org>
 <20130318174134.GB7852@quack.suse.cz>
 <20130318230259.GP5313@blackbox.djwong.org>
 <20130402170143.GA8910@blackbox.djwong.org>
 <20130403142019.GC5811@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130403142019.GC5811@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Shuge <shugelinux@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinnertech.com>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

On Wed 03-04-13 15:20:19, Mel Gorman wrote:
> On Tue, Apr 02, 2013 at 10:01:43AM -0700, Darrick J. Wong wrote:
> > Hi,
> > 
> > A couple of weeks have gone by without further comments about this patch.
> > 
> > Are you interested in the minor cleanups and added comments, or is the v2 patch
> > in -next good enough?
> > 
> > Apparently Mel Gorman's interested in this patchset too.  Mel: Most of stable
> > pages part 2 are already in upstream for 3.9... except this piece.  Are you
> > interested in having this piece in 3.9 also?  Or is 3.10 good enough for
> > everyone?
> > 
> 
> My understanding is that it only affects ARM and DEBUG_VM so there is a
> relatively small chance of this generating spurious bug reports.  However,
> 3.9 is still far enough away that I see no good reason to delay this patch
> until 3.10 either.
  No, actually with direct IO, anything that needs stable pages is going to
blow up quickly because pages attached to bio needn't be from page cache. So
I think it should better make it into 3.9.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
