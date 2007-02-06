Date: Tue, 6 Feb 2007 09:58:47 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/3] mm: make read_cache_page synchronous
Message-ID: <20070206085847.GA6487@wotan.suse.de>
References: <20070206054925.21042.50546.sendpatchset@linux.site> <20070206054957.21042.18724.sendpatchset@linux.site> <20070206002839.f02a47bc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206002839.f02a47bc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 06, 2007 at 12:28:39AM -0800, Andrew Morton wrote:
> > 
> > Also, a memory leak in sys_swapon().
> 
> Separate patch?

Gack, I'm an idiot, there is no memory leak :P

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
