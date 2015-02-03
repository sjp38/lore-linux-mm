Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 465046B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 11:00:48 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id a1so45310082wgh.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 08:00:46 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id do6si19445051wib.91.2015.02.03.08.00.45
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 08:00:45 -0800 (PST)
From: Daniel Sanders <Daniel.Sanders@imgtec.com>
Subject: RE: [PATCH 1/5] LLVMLinux: Correct size_index table before
 replacing the bootstrap kmem_cache_node.
Date: Tue, 3 Feb 2015 16:00:43 +0000
Message-ID: <E484D272A3A61B4880CDF2E712E9279F4591AFFB@hhmail02.hh.imgtec.org>
References: <1422970639-7922-1-git-send-email-daniel.sanders@imgtec.com>
 <1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
 <alpine.DEB.2.11.1502030913370.6059@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1502030913370.6059@gentwo.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> -----Original Message-----
> From: Christoph Lameter [mailto:cl@linux.com]
> Sent: 03 February 2015 15:15
> To: Daniel Sanders
> Cc: Pekka Enberg; David Rientjes; Joonsoo Kim; Andrew Morton; linux-
> mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 1/5] LLVMLinux: Correct size_index table before
> replacing the bootstrap kmem_cache_node.
>=20
> On Tue, 3 Feb 2015, Daniel Sanders wrote:
>=20
> > +++ b/mm/slab.c
> > @@ -1440,6 +1440,7 @@ void __init kmem_cache_init(void)
> >  	kmalloc_caches[INDEX_NODE] =3D create_kmalloc_cache("kmalloc-
> node",
> >  				kmalloc_size(INDEX_NODE),
> ARCH_KMALLOC_FLAGS);
> >  	slab_state =3D PARTIAL_NODE;
> > +	correct_kmalloc_cache_index_table();
>=20
> Lets call this
>=20
> 	setup_kmalloc_cache_index_table
>=20
> Please?

Sure, I've made the change in my repo. I'll wait a bit before re-sending th=
e patch in case others have feedback too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
