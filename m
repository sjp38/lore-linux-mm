Date: Thu, 5 Apr 2007 04:30:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] no ZERO_PAGE?
Message-ID: <20070405023026.GE11192@wotan.suse.de>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org> <6701.1175724355@turing-police.cc.vt.edu> <Pine.LNX.4.64.0704041724280.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704041724280.6730@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Valdis.Kletnieks@vt.edu, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 05:27:31PM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 4 Apr 2007, Valdis.Kletnieks@vt.edu wrote:
> > 
> > I'd not be surprised if there's sparse-matrix code out there that wants to
> > malloc a *huge* array (like a 1025x1025 array of numbers) that then only
> > actually *writes* to several hundred locations, and relies on the fact that
> > all the untouched pages read back all-zeros.
> 
> Good point. In fact, it doesn't need to be a malloc() - I remember people 
> doing this with Fortran programs and just having an absolutely incredibly 
> big BSS (with traditional Fortran, dymic memory allocations are just not 
> done).

Sparse matrices are one thing I worry about. I don't know enough about
HPC code to know whether they will be a problem. I know there exist
data structures to optimise sparse matrix storage...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
