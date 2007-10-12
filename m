Date: Fri, 12 Oct 2007 07:53:17 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] mm: avoid dirtying shared mappings on mlock
Message-ID: <20071012075317.591212ef@laptopd505.fenrus.org>
In-Reply-To: <1192186222.27435.22.camel@twins>
References: <11854939641916-git-send-email-ssouhlal@FreeBSD.org>
	<200710120257.05960.nickpiggin@yahoo.com.au>
	<1192185439.27435.19.camel@twins>
	<200710120414.11026.nickpiggin@yahoo.com.au>
	<1192186222.27435.22.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Suleiman Souhlal <ssouhlal@freebsd.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Suleiman Souhlal <suleiman@google.com>, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Oct 2007 12:50:22 +0200
> > > The pages will still be read-only due to dirty tracking, so the
> > > first write will still do page_mkwrite().
> > 
> > Which can SIGBUS, no?
> 
> Sure, but that is no different than any other mmap'ed write. I'm not
> seeing how an mlocked region is special here.
> 
> I agree it would be nice if mmap'ed writes would have better error
> reporting than SIGBUS, but such is life.

well... there's another consideration
people use mlock() in cases where they don't want to go to the
filesystem for paging and stuff as well (think the various iscsi
daemons and other things that get in trouble).. those kind of uses
really use mlock to avoid
1) IO to the filesystem
2) Needing memory allocations for pagefault like things
at least for the more "hidden" cases...

prefaulting everything ready pretty much gives them that... letting
things fault on demand... nicely breaks that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
