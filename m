Date: Wed, 4 Apr 2007 12:15:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] no ZERO_PAGE?
Message-Id: <20070404121533.cd222192.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
References: <20070329075805.GA6852@wotan.suse.de>
	<Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
	<20070330024048.GG19407@wotan.suse.de>
	<20070404033726.GE18507@wotan.suse.de>
	<Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007 08:35:30 -0700 (PDT) Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Does anybody do any performance testing on -mm?

http://test.kernel.org/perf/index.html has pretty graphs of lots of kernel versions
for a few benchmarks.  I'm not aware of any other organised effort along those
lines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
