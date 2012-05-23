Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 72FF86B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 11:39:12 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so16966939obb.14
        for <linux-mm@kvack.org>; Wed, 23 May 2012 08:39:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120518161932.147485968@linux.com>
References: <20120518161906.207356777@linux.com>
	<20120518161932.147485968@linux.com>
Date: Thu, 24 May 2012 00:39:11 +0900
Message-ID: <CAAmzW4Oxwq-Gd7ts3F1funk5-fwVOSHEBz2fh5Rno90E8nnG4Q@mail.gmail.com>
Subject: Re: [RFC] Common code 09/12] slabs: Extract a common function for kmem_cache_destroy
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

> +void __kmem_cache_destroy(struct kmem_cache *s)
> +{
> + =A0 =A0 =A0 kfree(s);
> + =A0 =A0 =A0 sysfs_slab_remove(s);
> =A0}
> -EXPORT_SYMBOL(kmem_cache_destroy);

sysfs_slab_remove(s) -> kfree(s) is correct order.
If not, it will break the system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
