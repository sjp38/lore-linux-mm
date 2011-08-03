Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C827B6B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 10:09:52 -0400 (EDT)
Date: Wed, 3 Aug 2011 09:09:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <alpine.DEB.2.00.1108020938200.1114@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1108030908100.24201@router.home>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com> <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com> <1312145146.24862.97.camel@jaguar>
 <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com> <CAOJsxLHB9jPNyU2qztbEHG4AZWjauCLkwUVYr--8PuBBg1=MCA@mail.gmail.com> <alpine.DEB.2.00.1108012101310.6871@chino.kir.corp.google.com> <alpine.DEB.2.00.1108020913180.18965@router.home>
 <alpine.DEB.2.00.1108020915370.1114@chino.kir.corp.google.com> <alpine.DEB.2.00.1108021131250.21126@router.home> <alpine.DEB.2.00.1108020938200.1114@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2 Aug 2011, David Rientjes wrote:

> On Tue, 2 Aug 2011, Christoph Lameter wrote:
>
> > The per cpu partial lists only add the need for more memory if other
> > processors have to allocate new pages because they do not have enough
> > partial slab pages to satisfy their needs. That can be tuned by a cap on
> > objects.
> >
>
> The netperf benchmark isn't representative of a heavy slab consuming
> workload, I routinely run jobs on these machines that use 20 times the
> amount of slab.  From what I saw in the earlier posting of the per-cpu
> partial list patch, the min_partial value is set to half of what it was
> previously as a per-node partial list.  Since these are 16-core, 4 node
> systems, that would mean that after a kmem_cache_shrink() on a cache that
> leaves empty slab on the partial lists that we've doubled the memory for
> slub's partial lists systemwide.

Cutting down the potential number of empty slabs that we might possible
keep around because we have no partial slabs per node increases memory
usage?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
