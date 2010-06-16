Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B1E426B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 18:15:59 -0400 (EDT)
Date: Thu, 17 Jun 2010 08:15:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: your mail
Message-ID: <20100616221541.GV6590@dastard>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276706031-29421-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 06:33:49PM +0200, Jan Kara wrote:
>   Hello,
> 
>   here is the fourth version of the writeback livelock avoidance patches
> for data integrity writes. To quickly summarize the idea: we tag dirty
> pages at the beginning of write_cache_pages with a new TOWRITE tag and
> then write only tagged pages to avoid parallel writers to livelock us.
> See changelogs of the patches for more details.
>   I have tested the patches with fsx and a test program I wrote which
> checks that if we crash after fsync, the data is indeed on disk.
>   If there are no more concerns, can these patches get merged?

Has it been run through xfstests? I'd suggest doing that at least
with XFS as there are several significant sync sanity tests for XFS
in the suite...

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
