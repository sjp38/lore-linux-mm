Date: Tue, 6 Feb 2007 06:53:28 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070206055328.GD16647@wotan.suse.de>
References: <20070204104609.GA29943@wotan.suse.de> <20070204025602.a5f8c53a.akpm@linux-foundation.org> <20070204110317.GA9034@wotan.suse.de> <20070204031549.203f7b47.akpm@linux-foundation.org> <20070204151051.GB12771@wotan.suse.de> <20070204103620.33c24cad.akpm@linux-foundation.org> <20070206022549.GB31476@wotan.suse.de> <20070206044146.GA11856@wotan.suse.de> <20070205213006.0ea2d918.akpm@linux-foundation.org> <20070206054905.GC16647@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206054905.GC16647@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 06, 2007 at 06:49:05AM +0100, Nick Piggin wrote:
> > - If the get_user() doesn't fault, and if we're copying from and to the
> >   same page, we know that we've locked it, so nobody will be able to unmap
> >   it while we're copying from it.
> > 
> > Close, but no cigar!  This is still vulnerable to Hugh's ab/ba deadlock
> > scenario.
> 
> Yes I considered this too. Hard isn't it?

BTW, there are two different abba deadlocks. It's all documented in the
patch 9/9 description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
