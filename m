Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 135336B0169
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 10:15:09 -0400 (EDT)
Date: Tue, 2 Aug 2011 09:15:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <alpine.DEB.2.00.1108012101310.6871@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1108020913180.18965@router.home>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com> <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com> <1312145146.24862.97.camel@jaguar>
 <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com> <CAOJsxLHB9jPNyU2qztbEHG4AZWjauCLkwUVYr--8PuBBg1=MCA@mail.gmail.com> <alpine.DEB.2.00.1108012101310.6871@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 1 Aug 2011, David Rientjes wrote:

> On Mon, 1 Aug 2011, Pekka Enberg wrote:
>
> > Btw, I haven't measured this recently but in my testing, SLAB has
> > pretty much always used more memory than SLUB. So 'throwing more
> > memory at the problem' is definitely a reasonable approach for SLUB.
> >
>
> Yes, slub _did_ use more memory than slab until the alignment of
> struct page.  That cost an additional 128MB on each of these 64GB
> machines, while the total slab usage on the client machine systemwide is
> ~75MB while running netperf TCP_RR with 160 threads.

I guess that calculation did not include metadata structures (alien caches
and the NR_CPU arrays in kmem_cache) etc? These are particularly costly on SLAB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
