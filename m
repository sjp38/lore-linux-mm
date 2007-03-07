Date: Wed, 7 Mar 2007 09:27:55 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307082755.GA25733@elte.hu>
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070221023735.6306.83373.sendpatchset@linux.site> <20070306225101.f393632c.akpm@linux-foundation.org> <20070307070853.GB15877@wotan.suse.de> <20070307081948.GA9563@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070307081948.GA9563@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <npiggin@suse.de> wrote:

> If it doesn't look very impressive, it could be because it leaves all 
> the old crud around for backwards compatibility (the worst offenders 
> are removed in patch 6/6).
> 
> If you look at the patchset as a whole, it removes about 250 lines, 
> mostly of (non trivial) duplicated code in filemap.c memory.c shmem.c 
> fremap.c, that is nonlinear pages specific and doesn't get anywhere 
> near the testing that the linear fault path does.
> 
> A minimal fix for nonlinear pages would have required changing all 
> ->populate handlers, which I simply thought was not very productive 
> considering the testing and coverage issues, and that I was going to 
> rewrite the nonlinear path anyway.
> 
> If you like, you can consider patches 1,2,3 as the fix, and ignore 
> nonlinear (hey, it doesn't even bother checking truncate_count 
> today!).
> 
> Then 4,5,6 is the fault/nonlinear rewrite, take it or leave it. I 
> thought you would have liked the patches...

btw., if we decide that nonlinear isnt worth the continuing maintainance 
pain, we could internally implement/emulate sys_remap_file_pages() via a 
call to mremap() and essentially deprecate it, without breaking the ABI 
- and remove all the nonlinear code. (This would split fremap areas into 
separate vmas)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
