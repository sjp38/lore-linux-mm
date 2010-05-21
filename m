Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B5876B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 16:23:30 -0400 (EDT)
From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Fri, 21 May 2010 13:23:27 -0700
Subject: RE: [PATCH] slub: move kmem_cache_node into it's own cacheline
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F256284B0C1@orsmsx501.amr.corp.intel.com>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com>
 <alpine.DEB.2.00.1005211305340.14851@router.home>
 <80769D7B14936844A23C0C43D9FBCF0F256284AECC@orsmsx501.amr.corp.intel.com>
 <alpine.DEB.2.00.1005211322320.14851@router.home>
 <alpine.DEB.2.00.1005211330570.14851@router.home>
In-Reply-To: <alpine.DEB.2.00.1005211330570.14851@router.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> struct kmem_cache is allocated without any alignment so the alignment
> spec does not work.
>=20
> If you want this then you also need to align struct kmem_cache.
> internode aligned would require the kmem_cache to be page aligned. So
> lets drop the hunk from this patch for now. A separate patch may
> convince us to merge aligning kmem_cache_node within kmem_cache.

I will pull that hunk out, test it, and resubmit within the next hour or so=
 if everything looks good.

Thanks,

Alex=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
