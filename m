Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06F926B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 05:50:02 -0500 (EST)
Date: Thu, 10 Nov 2011 10:51:00 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111110105100.23fa78f9@lxorguk.ukuu.org.uk>
In-Reply-To: <20111110100616.GD3083@suse.de>
References: <20111110100616.GD3083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 10 Nov 2011 10:06:16 +0000
Mel Gorman <mgorman@suse.de> wrote:

> Occasionally during large file copies to slow storage, there are still
> reports of user-visible stalls when THP is enabled. Reports on this
> have been intermittent and not reliable to reproduce locally but;

If you want to cause a massive stall take a cheap 32GB USB flash drive
plug it into an 8GB box and rsync a lot of small files to it. 400,000
emails in maildir format does the trick and can easily be simulated. The
drive drops to about 1-2 IOPS with all the small mucking around and the
backlog becomes massive.

> Internally in SUSE, I received a bug report related to stalls in firefox
> 	when using Java and Flash heavily while copying from NFS
> 	to VFAT on USB. It has not been confirmed to be the same problem
> 	but if it looks like a duck and quacks like a duck.....

With the 32GB USB flash rsync I see firefox block for up to 45 minutes
although operating entirely on an unrelated filesystem. I suspect it may
be a problem that is visible because an fsync is getting jammed up in
the mess.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
