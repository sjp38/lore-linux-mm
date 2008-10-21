From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] mm: fix anon_vma races
Date: Tue, 21 Oct 2008 13:45:14 +1100
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810190745420.5662@blonde.site> <Pine.LNX.4.64.0810200421150.3867@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0810200421150.3867@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810211345.14954.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 20 October 2008 14:26, Hugh Dickins wrote:
> On Sun, 19 Oct 2008, Hugh Dickins wrote:
> > On Sun, 19 Oct 2008, Nick Piggin wrote:
> > > There is already a page_mapped check in there. I'm just going to
> > > propose we move that down. No extra branchesin the fastpath. OK?
> >
> > That should be OK, yes.  Looking back at the history, I believe
> > I sited the page_mapped test where it is, partly for simpler flow,
> > and partly to avoid overhead of taking spinlock unnecessarily.
>
> Arrgh!  What terrible advice I gave you there, completely wrong:
> that's what happens when I rush a reply instead of thinking.
>
> I'm three-quarters through replying to Linus on this, and going
> into that detail, remember now why its placement is critical.
>
> Repeat the page_mapped check before returning if you wish,
> but do not remove the one that's there: see other mail for
> explanation.

Right, thanks for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
