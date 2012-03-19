Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 0A33A6B00EA
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 01:22:13 -0400 (EDT)
Date: Mon, 19 Mar 2012 13:16:36 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/4] Get rid of iput() from flusher thread
Message-ID: <20120319051636.GB5191@localhost>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331283748-12959-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 09, 2012 at 10:02:24AM +0100, Jan Kara wrote:
> 
>   Hi,
> 
>   this patch set changes writeback_sb_inodes() to avoid iput() which might
> be problematic (see patch 4 which tries to summarize our email discussions)
> for some filesystems.
> 
>   Patches 1 and 2 are trivial mostly unrelated fixes (Fengguang, can you can
> take these and merge them right away please?).

Sure, they have been tested in linux-next for some days.

> Patch 3 is a preparatory code
> reshuffle and patch 4 removes the __iget() / iput() from flusher thread.

These are pretty sane changes towards the right direction (in despite
of the complexities involved).

>   As a side note, your patches to offload writeback from kswapd to flusher
> thread then won't need iget/iput either if we pass page references as we talked
> so that should resolve most of the concerns.
> 
>   What do you think guys?

I appreciate the work a lot. Thank you for removing the major problem
with the patches on pageout writeback work :-)

Regards,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
