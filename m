Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 6EBB46B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:48:37 -0400 (EDT)
Date: Tue, 4 Sep 2012 22:48:36 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: C13 [13/14] Shrink __kmem_cache_create() parameter lists
In-Reply-To: <5044CE4B.8060203@parallels.com>
Message-ID: <000001399378925d-804836bb-4cb0-4d1a-a0de-4c6718a3ecb9-000000@email.amazonses.com>
References: <20120824160903.168122683@linux.com> <00000139596cab81-8759391f-4d20-494a-9c7c-a759363e2b87-000000@email.amazonses.com> <5044CDD0.4040403@parallels.com> <5044CE4B.8060203@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Mon, 3 Sep 2012, Glauber Costa wrote:

> Actually, Christoph, it would be a lot cleaner if you would just do
>
>    size_t size = cachep->size;
>
> in the beginning of this function. The resulting patch size would be a
> lot smaller since you don't need to patch the references, and would
> avoid mistakes like that altogether.

Ok. Done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
