Date: Mon, 28 Jan 2008 17:07:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Pull request: DMA pool updates
Message-Id: <20080128170734.3101b6aa.akpm@linux-foundation.org>
In-Reply-To: <20080129001147.GD31101@parisc-linux.org>
References: <20080129001147.GD31101@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008 17:11:47 -0700
Matthew Wilcox <matthew@wil.cx> wrote:

> 
> G'day Linus, mate
> 
> Could you pull the dmapool branch of
> git://git.kernel.org/pub/scm/linux/kernel/git/willy/misc.git please?

The usual form is, I believe,

	git://git.kernel.org/pub/scm/linux/kernel/git/willy/misc.git dmapool

Otherwise people get all confused and think it's an empty tree (like I just
did).

> All the patches have been posted to linux-kernel before, and various
> comments (and acks) have been taken into account.
> 
> It's a fairly nice performance improvement, so would be good to get in.
> It's survived a few hours of *mumble* high-stress database benchmark,
> so I have high confidence in its stability.

Could we please at least have a shortlog so we can find out what the patch
titles are so we can google them so we can find out what the heck you're
proposing we add to the kernel?

<does a pull, goes on an archive hunt>

It shouldn't be this hard!

There were no replies to v2 of the patch series.  It all looks reasonable
from a quick scan (assuming the patches are unchanged since then).

afaik these patches have been tested by nobody except thyself?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
