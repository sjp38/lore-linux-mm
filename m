Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7A8506B01B4
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 03:44:18 -0400 (EDT)
Date: Thu, 17 Jun 2010 09:43:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2 v4] Writeback livelock avoidance for data integrity
 writes
Message-ID: <20100617074350.GA3453@quack.suse.cz>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
 <20100616221541.GV6590@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616221541.GV6590@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Thu 17-06-10 08:15:41, Dave Chinner wrote:
> On Wed, Jun 16, 2010 at 06:33:49PM +0200, Jan Kara wrote:
> >   Hello,
> > 
> >   here is the fourth version of the writeback livelock avoidance patches
> > for data integrity writes. To quickly summarize the idea: we tag dirty
> > pages at the beginning of write_cache_pages with a new TOWRITE tag and
> > then write only tagged pages to avoid parallel writers to livelock us.
> > See changelogs of the patches for more details.
> >   I have tested the patches with fsx and a test program I wrote which
> > checks that if we crash after fsync, the data is indeed on disk.
> >   If there are no more concerns, can these patches get merged?
> 
> Has it been run through xfstests? I'd suggest doing that at least
> with XFS as there are several significant sync sanity tests for XFS
> in the suite...
  I've run it through XFSQA with ext3 & ext4 before submitting. I'm running
a test with xfs now.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
