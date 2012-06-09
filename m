Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 31B0F6B006E
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 11:57:49 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so5410565obb.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 08:57:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206081401090.28466@router.home>
References: <1339176197-13270-1-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1206081401090.28466@router.home>
Date: Sun, 10 Jun 2012 00:57:48 +0900
Message-ID: <CAAmzW4Nt2ev-M_Mw=xTaJEsRgKxrPNnz=rXrJenNA-6bEvZKtQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] slub: change declare of get_slab() to inline at all times
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/6/9 Christoph Lameter <cl@linux.com>:
> On Sat, 9 Jun 2012, Joonsoo Kim wrote:
>
>> -static struct kmem_cache *get_slab(size_t size, gfp_t flags)
>> +static __always_inline struct kmem_cache *get_slab(size_t size, gfp_t flags)
>
> I thought that the compiler felt totally free to inline static functions
> at will? This may be a matter of compiler optimization settings. I can
> understand the use of always_inline in a header file but why in a .c file?

Yes, but the compiler with -O2 doesn't inline get_slab() which
declared just 'static'.
I think that inlining get_slab() have a performance benefit, so add
'__always_inline' to declare of get_slab().
Other functions like slab_alloc, slab_free also use 'always_inline' in
.c file (slub.c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
