From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm: avoid dirtying shared mappings on mlock
Date: Fri, 12 Oct 2007 22:23:01 +1000
References: <11854939641916-git-send-email-ssouhlal@FreeBSD.org> <200710120414.11026.nickpiggin@yahoo.com.au> <1192186222.27435.22.camel@twins>
In-Reply-To: <1192186222.27435.22.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710122223.02061.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Suleiman Souhlal <suleiman@google.com>, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Friday 12 October 2007 20:50, Peter Zijlstra wrote:
> On Fri, 2007-10-12 at 04:14 +1000, Nick Piggin wrote:
> > On Friday 12 October 2007 20:37, Peter Zijlstra wrote:

> > > The pages will still be read-only due to dirty tracking, so the first
> > > write will still do page_mkwrite().
> >
> > Which can SIGBUS, no?
>
> Sure, but that is no different than any other mmap'ed write. I'm not
> seeing how an mlocked region is special here.

Well it is a change in behaviour (admittedly, so was the change
to SIGBUS mmaped writes in the first place). It's a matter of
semantics I guess. Is the current behaviour actually a _problem_
for anyone? If not, then do we need to change it?

I'm not saying it does matter, just that it might matter ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
