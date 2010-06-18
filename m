Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2C7866B01B5
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 03:01:43 -0400 (EDT)
Date: Fri, 18 Jun 2010 17:01:11 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 0/2 v4] Writeback livelock avoidance for data integrity
 writes
Message-ID: <20100618070111.GE6138@laptop>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
 <20100616221541.GV6590@dastard>
 <20100617074350.GA3453@quack.suse.cz>
 <20100618061111.GB6590@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100618061111.GB6590@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 18, 2010 at 04:11:11PM +1000, Dave Chinner wrote:
> On Thu, Jun 17, 2010 at 09:43:50AM +0200, Jan Kara wrote:
> > On Thu 17-06-10 08:15:41, Dave Chinner wrote:
> > > On Wed, Jun 16, 2010 at 06:33:49PM +0200, Jan Kara wrote:
> > > >   Hello,
> > > > 
> > > >   here is the fourth version of the writeback livelock avoidance patches
> > > > for data integrity writes. To quickly summarize the idea: we tag dirty
> > > > pages at the beginning of write_cache_pages with a new TOWRITE tag and
> > > > then write only tagged pages to avoid parallel writers to livelock us.
> > > > See changelogs of the patches for more details.
> > > >   I have tested the patches with fsx and a test program I wrote which
> > > > checks that if we crash after fsync, the data is indeed on disk.
> > > >   If there are no more concerns, can these patches get merged?
> > > 
> > > Has it been run through xfstests? I'd suggest doing that at least
> > > with XFS as there are several significant sync sanity tests for XFS
> > > in the suite...
> >   I've run it through XFSQA with ext3 & ext4 before submitting. I'm running
> > a test with xfs now.
> 
> Cool. if there are no problems then I'm happy with this ;)

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
