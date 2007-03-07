Subject: Re: [RFC][PATCH] mm: fix page_mkclean() vs non-linear vmas
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1173291120.4718.40.camel@lappy>
References: <1173264462.6374.140.camel@twins>
	 <20070307110035.GE5555@wotan.suse.de> <1173268086.6374.157.camel@twins>
	 <20070307121730.GC18704@wotan.suse.de> <1173271286.6374.166.camel@twins>
	 <20070307130851.GE18704@wotan.suse.de> <1173273562.6374.175.camel@twins>
	 <20070307133649.GF18704@wotan.suse.de> <1173275532.6374.183.camel@twins>
	 <1173278067.6374.188.camel@twins>  <20070307150102.GH18704@wotan.suse.de>
	 <1173286682.6374.191.camel@twins>
	 <Pine.LNX.4.64.0703070959430.5963@woody.linux-foundation.org>
	 <1173291120.4718.40.camel@lappy>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 19:24:39 +0100
Message-Id: <1173291879.14351.3.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, Jeff Dike <jdike@addtoit.com>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-07 at 19:12 +0100, Peter Zijlstra wrote:
> On Wed, 2007-03-07 at 10:00 -0800, Linus Torvalds wrote:
> > 
> > On Wed, 7 Mar 2007, Peter Zijlstra wrote:
> > > 
> > > I'm not at all happy with this, but plain disallowing remap_file_pages on bdis
> > > without BDI_CAP_NO_WRITEBACK seems to offend some people, hence restrict it to
> > > root only.
> > 
> > I don't think that's a viable approach. Nonlinear mappings would normally 
> > be used by databases, and you don't want to limit databases to be run by 
> > root only.
> 
> It was claimed that they use it on tmpfs only, not on a 'real'
> filesystem.

More specifically, databases want to use direct IO (I know you hate it)
and use the nonlinear vma as buffer area to feed this direct IO

Mapped IO is unsuited for databases in its current form due to the way
IO errors are handled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
