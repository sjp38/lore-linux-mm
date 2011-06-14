Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A84556B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 08:19:14 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p5ECJCBO010181
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 05:19:12 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz24.hot.corp.google.com with ESMTP id p5ECJ6lZ013512
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 05:19:11 -0700
Received: by pzk4 with SMTP id 4so3240246pzk.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 05:19:06 -0700 (PDT)
Date: Tue, 14 Jun 2011 05:18:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] slub: fix kernel BUG at mm/slub.c:1950!
In-Reply-To: <1308027078.2874.1005.camel@pasglop>
Message-ID: <alpine.LSU.2.00.1106140515470.30002@sister.anvils>
References: <alpine.LSU.2.00.1106121842250.31463@sister.anvils> <alpine.DEB.2.00.1106131258300.3108@router.home> <1307990048.11288.3.camel@jaguar> <alpine.DEB.2.00.1106131428560.5601@router.home> <BANLkTi=RYq0Dd210VC+NeTXWWuFbz7cxeg@mail.gmail.com>
 <BANLkTik-KGtuoVFKvy_rk7voBRAxSsR9FRg0fhb0k3NCSg-fWQ@mail.gmail.com> <1308027078.2874.1005.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, 14 Jun 2011, Benjamin Herrenschmidt wrote:
> On Mon, 2011-06-13 at 14:00 -0700, Hugh Dickins wrote:
> > On Mon, Jun 13, 2011 at 1:34 PM, Pekka Enberg <penberg@kernel.org> wrote:
> > > On Mon, Jun 13, 2011 at 10:29 PM, Christoph Lameter <cl@linux.com> wrote:
> > >> On Mon, 13 Jun 2011, Pekka Enberg wrote:
> > >>
> > >>> > Hmmm.. The allocpercpu in alloc_kmem_cache_cpus should take care of the
> > >>> > alignment. Uhh.. I see that a patch that removes the #ifdef CMPXCHG_LOCAL
> > >>> > was not applied? Pekka?
> > >>>
> > >>> This patch?
> > >>>
> > >>> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=d4d84fef6d0366b585b7de13527a0faeca84d9ce
> > >>>
> > >>> It's queued and will be sent to Linus soon.
> > >>
> > >> Ok it will also fix Hugh's problem then.
> > >
> > > It's in Linus' tree now. Hugh, can you please confirm it fixes your machine too?
> > 
> > I expect it to, thanks: I'll confirm tonight.
> 
> From report to resolution before I got to read the thread, that's how I
> like them ! Thanks guys :-)

Confirmed: fixed in 3.0-rc3 - thank you!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
