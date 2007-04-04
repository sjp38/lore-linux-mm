Date: Wed, 4 Apr 2007 11:51:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070404115105.ebaff52a.akpm@linux-foundation.org>
In-Reply-To: <20070404130918.GK2986@holomorphy.com>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<20070404130918.GK2986@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007 06:09:18 -0700 William Lee Irwin III <wli@holomorphy.com> wrote:

> 
> On Tue, Apr 03, 2007 at 04:29:37PM -0400, Jakub Jelinek wrote:
> > void *
> > tf (void *arg)
> > {
> >   (void) arg;
> >   size_t ps = sysconf (_SC_PAGE_SIZE);
> >   void *p = mmap (NULL, 128 * ps, PROT_READ | PROT_WRITE,
> >                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
> >   if (p == MAP_FAILED)
> >     exit (1);
> >   int i;
> 
> Oh dear.

what's all this about?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
