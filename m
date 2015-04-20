Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id E77D16B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 12:16:06 -0400 (EDT)
Received: by wgin8 with SMTP id n8so184517298wgi.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 09:16:06 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id r1si16791101wic.112.2015.04.20.09.16.05
        for <linux-mm@kvack.org>;
        Mon, 20 Apr 2015 09:16:05 -0700 (PDT)
From: Daniel Sanders <Daniel.Sanders@imgtec.com>
Subject: RE: [PATCH v5] slab: Correct size_index table before replacing the
 bootstrap kmem_cache_node.
Date: Mon, 20 Apr 2015 16:16:03 +0000
Message-ID: <E484D272A3A61B4880CDF2E712E9279F4597C0A4@hhmail02.hh.imgtec.org>
References: <1424791511-11407-2-git-send-email-daniel.sanders@imgtec.com>
 <1429542335-8379-1-git-send-email-daniel.sanders@imgtec.com>
 <alpine.DEB.2.11.1504201041530.2264@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1504201041530.2264@gentwo.org>
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
> Sent: 20 April 2015 16:43
> To: Daniel Sanders
> Cc: Pekka Enberg; David Rientjes; Joonsoo Kim; Andrew Morton; linux-
> mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v5] slab: Correct size_index table before replacing t=
he
> bootstrap kmem_cache_node.
>=20
> On Mon, 20 Apr 2015, Daniel Sanders wrote:
>=20
> > This patch moves the initialization of the size_index table slightly
> > earlier so that the first few kmem_cache_node's can be safely allocated
> > when KMALLOC_MIN_SIZE is large.
>=20
> I have seen this patch and acked it before.
>=20
> Acked-by: Christoph Lameter <cl@linux.com>

Sorry, I must have forgotten to add it to the commit in my repo. Thanks for=
 looking at the patch again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
