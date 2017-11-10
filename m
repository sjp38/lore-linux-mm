Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD59F280298
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 12:11:16 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id p7so6803381qkd.8
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 09:11:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y124sor6932945qke.55.2017.11.10.09.11.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 09:11:15 -0800 (PST)
Date: Fri, 10 Nov 2017 12:11:12 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 2/6] writeback: allow for dirty metadata accounting
Message-ID: <20171110171111.idzazbjs26vh7nnb@destiny>
References: <1510255861-8020-1-git-send-email-josef@toxicpanda.com>
 <1510255861-8020-2-git-send-email-josef@toxicpanda.com>
 <20171110042533.GT4094@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110042533.GT4094@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Fri, Nov 10, 2017 at 03:25:33PM +1100, Dave Chinner wrote:
> On Thu, Nov 09, 2017 at 02:30:57PM -0500, Josef Bacik wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > Provide a mechanism for file systems to indicate how much dirty metadata they
> > are holding.  This introduces a few things
> > 
> > 1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
> > 2) WB stat for dirty metadata.  This way we know if we need to try and call into
> > the file system to write out metadata.  This could potentially be used in the
> > future to make balancing of dirty pages smarter.
> 
> Ok, so when you have 64k page size and 4k metadata block size and
> you're using kmalloc() to allocate the storage for the metadata,
> how do we make use of all this page-based metadata accounting
> stuff?

Sigh, I completely fucked this up.  I just found whatever my most recent local
branch was, forward ported it, and have been testing it for a few weeks to make
sure it was rock solid and sent it out.  I completely forgot I had redone all of
this stuff to count with bytes instead of pages specifically for this use case.
I have no idea where those patches went in my local tree but I've pulled down
the most recent versions of the patches from the mailinglist and will start
hammering on those again.  Sorry,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
