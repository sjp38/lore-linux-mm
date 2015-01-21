Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7546B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 17:26:45 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so23185876pdb.11
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 14:26:45 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id ko10si9729720pbd.171.2015.01.21.14.26.42
        for <linux-mm@kvack.org>;
        Wed, 21 Jan 2015 14:26:43 -0800 (PST)
Date: Thu, 22 Jan 2015 09:26:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 0/6] xfs: truncate vs page fault IO exclusion
Message-ID: <20150121222639.GJ16552@dastard>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
 <20150108122448.GA18034@infradead.org>
 <20150112174258.GN4468@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112174258.GN4468@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 12, 2015 at 06:42:58PM +0100, Jan Kara wrote:
> On Thu 08-01-15 04:24:48, Christoph Hellwig wrote:
> > > This patchset passes xfstests and various benchmarks and stress
> > > workloads, so the real question is now:
> > > 
> > > 	What have I missed?
> > > 
> > > Comments, thoughts, flames?
> > 
> > Why is this done in XFS and not in generic code?
>   I was also thinking about this. In the end I decided not to propose this
> since the new rw-lock would grow struct inode and is actually necessary
> only for filesystems implementing hole punching AFAICS. And that isn't
> supported by that many filesystems. So fs private implementation which
> isn't that complicated looked like a reasonable solution to me...

Ok, so it seems that doing this in the filesystem itself as an
initial solution is the way to move forward. Given that, this
patchset has run through regression and stress testing for a couple
of weeks without uncovering problems, so now I'm looking for reviews
so I can commit it. Anyone?

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
