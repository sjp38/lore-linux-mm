Date: Wed, 7 Feb 2007 04:13:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem
Message-ID: <20070207031304.GB31074@wotan.suse.de>
References: <20070206054925.21042.50546.sendpatchset@linux.site> <20070206225857.GV44411608@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206225857.GV44411608@melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 07, 2007 at 09:58:57AM +1100, David Chinner wrote:
> On Tue, Feb 06, 2007 at 09:02:01AM +0100, Nick Piggin wrote:
> > Still no independent confirmation as to whether this is a problem or not.
> > I think it is, so I'll propose this patchset to fix it. Patch 1/3 has a
> > reasonable description of the problem.
> > 
> 
> Nick, can you include a diffstat at the head of your patches? Makes
> it much easier to see what the scope of the changes are when you
> are changing code in several filesystems....

Good idea, I'll do that.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
