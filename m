Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 91CD46B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 11:38:39 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so3577114wgh.23
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 08:38:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013f444bf6e9-d535ba8b-df9e-4053-9ed4-eaba75e2cfd2-000000@email.amazonses.com>
References: <20130614195500.373711648@linux.com>
	<0000013f444bf6e9-d535ba8b-df9e-4053-9ed4-eaba75e2cfd2-000000@email.amazonses.com>
Date: Tue, 18 Jun 2013 18:38:37 +0300
Message-ID: <CAOJsxLHPWJdc6Qy9e7-s-7+KWPOgbs8ZR+JpxWb9sykyC9Um8A@mail.gmail.com>
Subject: Re: [3.11 3/4] Move kmalloc_node functions to common code
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

On Fri, Jun 14, 2013 at 11:06 PM, Christoph Lameter <cl@linux.com> wrote:
> The kmalloc_node functions of all slab allcoators are similar now so
> lets move them into slab.h. This requires some function naming changes
> in slob.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

I'm seeing this after "make defconfig" on x86-64:

  CC      mm/slub.o
mm/slub.c:2445:7: error: conflicting types for =91kmem_cache_alloc_node_tra=
ce=92
include/linux/slab.h:311:14: note: previous declaration of
=91kmem_cache_alloc_node_trace=92 was here
mm/slub.c:2455:1: error: conflicting types for =91kmem_cache_alloc_node_tra=
ce=92
include/linux/slab.h:311:14: note: previous declaration of
=91kmem_cache_alloc_node_trace=92 was here
make[1]: *** [mm/slub.o] Error 1
make: *** [mm/slub.o] Error 2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
