Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 343646B0036
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 12:14:44 -0400 (EDT)
Received: by mail-wg0-f53.google.com with SMTP id y10so3071460wgg.8
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 09:14:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013f583ce865-d803292b-f217-4fb7-a8c2-4366334cb425-000000@email.amazonses.com>
References: <20130614195500.373711648@linux.com>
	<0000013f444bf6e9-d535ba8b-df9e-4053-9ed4-eaba75e2cfd2-000000@email.amazonses.com>
	<CAOJsxLHPWJdc6Qy9e7-s-7+KWPOgbs8ZR+JpxWb9sykyC9Um8A@mail.gmail.com>
	<0000013f583ce865-d803292b-f217-4fb7-a8c2-4366334cb425-000000@email.amazonses.com>
Date: Sun, 7 Jul 2013 19:14:42 +0300
Message-ID: <CAOJsxLGqaEindeHh9fKgWj7dFToRpwn=50wB4U33bBOT41BdQA@mail.gmail.com>
Subject: Re: [3.11 3/4] Move kmalloc_node functions to common code
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

On Tue, Jun 18, 2013 at 8:02 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 18 Jun 2013, Pekka Enberg wrote:
>
>> I'm seeing this after "make defconfig" on x86-64:
>>
>>   CC      mm/slub.o
>> mm/slub.c:2445:7: error: conflicting types for =EF=BF=BDkmem_cache_alloc=
_node_trace=EF=BF=BD
>> include/linux/slab.h:311:14: note: previous declaration of
>> =EF=BF=BDkmem_cache_alloc_node_trace=EF=BF=BD was here
>> mm/slub.c:2455:1: error: conflicting types for =EF=BF=BDkmem_cache_alloc=
_node_trace=EF=BF=BD
>> include/linux/slab.h:311:14: note: previous declaration of
>> =EF=BF=BDkmem_cache_alloc_node_trace=EF=BF=BD was here
>> make[1]: *** [mm/slub.o] Error 1
>> make: *** [mm/slub.o] Error 2
>
> Gosh I dropped the size_t parameter from these functions. CONFIG_TRACING
> needs these.
>
> Subject: Fix kmem_cache_alloc*_trace parameters
>
> The size parameter is needed.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Can you please resend as a single patch against slab/next that compiles?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
