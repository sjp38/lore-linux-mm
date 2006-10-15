Date: Sun, 15 Oct 2006 17:57:27 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: RRe: [patch 6/6] mm: fix pagecache write deadlocks
Message-ID: <20061015155727.GA539@wotan.suse.de>
References: <20061013143516.15438.8802.sendpatchset@linux.site> <20061013143616.15438.77140.sendpatchset@linux.site> <1160912230.5230.23.camel@lappy> <20061015115656.GA25243@wotan.suse.de> <1160920269.5230.29.camel@lappy> <20061015141953.GC25243@wotan.suse.de> <1160927224.5230.36.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1160927224.5230.36.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux Memory Management <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, ralf@linux-mips.org, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 15, 2006 at 05:47:03PM +0200, Peter Zijlstra wrote:
> > 
> > And we should really decouple it from preempt entirely, in case we
> > ever want to check for it some other way in the pagefault handler.
> 
> How about we make sure all kmap_atomic implementations behave properly 
> and make in_atomic true.

Hmm, but you may not be doing a copy*user within the kmap. And you may
want an atomic copy*user not within a kmap (maybe).

I think it really would be more logical to do it in a wrapper function
pagefault_disable() pagefault_enable()? ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
