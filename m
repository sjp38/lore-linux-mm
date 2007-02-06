Date: Wed, 7 Feb 2007 09:58:57 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem
Message-ID: <20070206225857.GV44411608@melbourne.sgi.com>
References: <20070206054925.21042.50546.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206054925.21042.50546.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 06, 2007 at 09:02:01AM +0100, Nick Piggin wrote:
> Still no independent confirmation as to whether this is a problem or not.
> I think it is, so I'll propose this patchset to fix it. Patch 1/3 has a
> reasonable description of the problem.
> 

Nick, can you include a diffstat at the head of your patches? Makes
it much easier to see what the scope of the changes are when you
are changing code in several filesystems....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
