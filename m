Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6136B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 16:04:54 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p78K4mVV010157
	for <linux-mm@kvack.org>; Mon, 8 Aug 2011 13:04:48 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz17.hot.corp.google.com with ESMTP id p78K4X9e030955
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 8 Aug 2011 13:04:46 -0700
Received: by pzk4 with SMTP id 4so3061133pzk.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 13:04:44 -0700 (PDT)
Date: Mon, 8 Aug 2011 13:04:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <alpine.DEB.2.00.1108030908100.24201@router.home>
Message-ID: <alpine.DEB.2.00.1108081303220.7792@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com> <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com> <1312145146.24862.97.camel@jaguar>
 <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com> <CAOJsxLHB9jPNyU2qztbEHG4AZWjauCLkwUVYr--8PuBBg1=MCA@mail.gmail.com> <alpine.DEB.2.00.1108012101310.6871@chino.kir.corp.google.com> <alpine.DEB.2.00.1108020913180.18965@router.home>
 <alpine.DEB.2.00.1108020915370.1114@chino.kir.corp.google.com> <alpine.DEB.2.00.1108021131250.21126@router.home> <alpine.DEB.2.00.1108020938200.1114@chino.kir.corp.google.com> <alpine.DEB.2.00.1108030908100.24201@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 3 Aug 2011, Christoph Lameter wrote:

> > The netperf benchmark isn't representative of a heavy slab consuming
> > workload, I routinely run jobs on these machines that use 20 times the
> > amount of slab.  From what I saw in the earlier posting of the per-cpu
> > partial list patch, the min_partial value is set to half of what it was
> > previously as a per-node partial list.  Since these are 16-core, 4 node
> > systems, that would mean that after a kmem_cache_shrink() on a cache that
> > leaves empty slab on the partial lists that we've doubled the memory for
> > slub's partial lists systemwide.
> 
> Cutting down the potential number of empty slabs that we might possible
> keep around because we have no partial slabs per node increases memory
> usage?
> 

You halved the number of min_partial, but there are 16 partial lists on 
these machines because they are per-cpu instead of 4 partial lists when 
they were per-node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
