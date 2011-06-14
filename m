Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 264286B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 01:00:08 -0400 (EDT)
Subject: Re: [PATCH] slub: fix kernel BUG at mm/slub.c:1950!
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <BANLkTik-KGtuoVFKvy_rk7voBRAxSsR9FRg0fhb0k3NCSg-fWQ@mail.gmail.com>
References: <alpine.LSU.2.00.1106121842250.31463@sister.anvils>
	 <alpine.DEB.2.00.1106131258300.3108@router.home>
	 <1307990048.11288.3.camel@jaguar>
	 <alpine.DEB.2.00.1106131428560.5601@router.home>
	 <BANLkTi=RYq0Dd210VC+NeTXWWuFbz7cxeg@mail.gmail.com>
	 <BANLkTik-KGtuoVFKvy_rk7voBRAxSsR9FRg0fhb0k3NCSg-fWQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 14 Jun 2011 14:51:18 +1000
Message-ID: <1308027078.2874.1005.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon, 2011-06-13 at 14:00 -0700, Hugh Dickins wrote:
> On Mon, Jun 13, 2011 at 1:34 PM, Pekka Enberg <penberg@kernel.org> wrote:
> > On Mon, Jun 13, 2011 at 10:29 PM, Christoph Lameter <cl@linux.com> wrote:
> >> On Mon, 13 Jun 2011, Pekka Enberg wrote:
> >>
> >>> > Hmmm.. The allocpercpu in alloc_kmem_cache_cpus should take care of the
> >>> > alignment. Uhh.. I see that a patch that removes the #ifdef CMPXCHG_LOCAL
> >>> > was not applied? Pekka?
> >>>
> >>> This patch?
> >>>
> >>> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=d4d84fef6d0366b585b7de13527a0faeca84d9ce
> >>>
> >>> It's queued and will be sent to Linus soon.
> >>
> >> Ok it will also fix Hugh's problem then.
> >
> > It's in Linus' tree now. Hugh, can you please confirm it fixes your machine too?
> 
> I expect it to, thanks: I'll confirm tonight.

>From report to resolution before I got to read the thread, that's how I
like them ! Thanks guys :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
