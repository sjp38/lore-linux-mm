Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 40C236B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 08:50:50 -0400 (EDT)
Message-ID: <501A77A4.1050005@parallels.com>
Date: Thu, 2 Aug 2012 16:50:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [question] how to increase the number of object on cache?
References: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com>
In-Reply-To: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Joo <sjoo@nvidia.com>
Cc: "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/02/2012 04:20 PM, Shawn Joo wrote:
> Dear Experts,
>=20
> =20
>=20
> I would like to know a mechanism, how to increase the number of object
> and where the memory is from.
>=20
> (because when cache is created by "kmem_cache_create", there is only
> object size, but no number of the object)
>=20
> For example, =93size-65536=94 does not have available memory from below d=
ump.
>=20
> In that state, if memory allocation is requested to =93size-65536=94,
>=20
> 1.     How to allocate/increase the number of object on =93size-65536=94?
>=20
> 2.     Where is the new allocated memory from? (from buddy?)
>=20
> =20

I am not sure I fully understand your question. But if you refer to
something like "from where does the object allocators get their memory
when more is needed", then yes, they will allocate the necessary number
of pages from the standard page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
