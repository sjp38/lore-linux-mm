Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B3D126B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 16:44:31 -0400 (EDT)
Date: Fri, 21 May 2010 15:41:16 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: RE: [PATCH] slub: move kmem_cache_node into it's own cacheline
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F256284B0C1@orsmsx501.amr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1005211537530.16703@router.home>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com> <alpine.DEB.2.00.1005211305340.14851@router.home> <80769D7B14936844A23C0C43D9FBCF0F256284AECC@orsmsx501.amr.corp.intel.com> <alpine.DEB.2.00.1005211322320.14851@router.home>
 <alpine.DEB.2.00.1005211330570.14851@router.home> <80769D7B14936844A23C0C43D9FBCF0F256284B0C1@orsmsx501.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010, Duyck, Alexander H wrote:

> Christoph Lameter wrote:
> > struct kmem_cache is allocated without any alignment so the alignment
> > spec does not work.
> >
> > If you want this then you also need to align struct kmem_cache.
> > internode aligned would require the kmem_cache to be page aligned. So
> > lets drop the hunk from this patch for now. A separate patch may
> > convince us to merge aligning kmem_cache_node within kmem_cache.
>
> I will pull that hunk out, test it, and resubmit within the next hour or so if everything looks good.

Again internode aligned may need page alignment. You may be getting into
messy issues. The architectures requiring internode alignment are NUMA
anyways so it may not matter because you only have local_node for the SMP
case.

Cacheline alignment therefore may be sufficient. But the variables at the
tail of the kmem_cache structure are mostly read only. Therefore may be
just forget about the alignment. It likely makes no difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
