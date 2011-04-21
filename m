Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 103A18D0040
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:33:49 -0400 (EDT)
Date: Thu, 21 Apr 2011 13:33:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303403847.4025.11.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104211328000.5741@router.home>
References: <1303337718.2587.51.camel@mulgrave.site>  <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com>  <20110421221712.9184.A69D9226@jp.fujitsu.com> <1303403847.4025.11.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>

On Thu, 21 Apr 2011, James Bottomley wrote:

> On Thu, 2011-04-21 at 22:16 +0900, KOSAKI Motohiro wrote:
> > > This should fix the remaining architectures so they can use CONFIG_SLUB,
> > > but I hope it can be tested by the individual arch maintainers like you
> > > did for parisc.
> >
> > ia64 and mips have CONFIG_ARCH_POPULATES_NODE_MAP and it initialize
> > N_NORMAL_MEMORY automatically if my understand is correct.
> > (plz see free_area_init_nodes)
> >
> > I guess alpha and m32r have no active developrs. only m68k seems to be need
> > fix and we have a chance to get a review...
>
> Actually, it's not quite a fix yet, I'm afraid.  I've just been
> investigating why my main 4 way box got slower with kernel builds:
> Apparently userspace processes are now all stuck on CPU0, so we're
> obviously tripping over some NUMA scheduling stuff that's missing.

The simplest solution may be to move these arches to use SPARSE instead.
AFAICT this was relatively easy for the arm guys.

Here is short guide on how to do that from the mips people:

http://www.linux-mips.org/archives/linux-mips/2008-08/msg00154.html

http://mytechkorner.blogspot.com/2010/12/sparsemem.html

Dave Hansen, Mel: Can you provide us with some help? (Its Easter and so
the europeans may be off for awhile)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
