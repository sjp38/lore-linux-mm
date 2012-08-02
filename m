Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id D7E036B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 08:56:03 -0400 (EDT)
From: Shawn Joo <sjoo@nvidia.com>
Date: Thu, 2 Aug 2012 20:55:58 +0800
Subject: RE: [question] how to increase the number of object on cache?
Message-ID: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDF1@HKMAIL02.nvidia.com>
References: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com>
 <501A77A4.1050005@parallels.com>
In-Reply-To: <501A77A4.1050005@parallels.com>
MIME-Version: 1.0
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>> then yes, they will allocate the necessary number of pages from the st=
andard page allocator.
Who is "the standard page allocator" for cache in /proc/slabinfo, e.g. "s=
ize-65536" ?
I believe one of allocator is buddy. who else?

Thanks,
Seongho(Shawn)


-----Original Message-----
From: Glauber Costa [mailto:glommer@parallels.com]=20
Sent: Thursday, August 02, 2012 9:51 PM
To: Shawn Joo
Cc: cl@linux-foundation.org; penberg@kernel.org; mpm@selenic.com; linux-m=
m@kvack.org
Subject: Re: [question] how to increase the number of object on cache?

On 08/02/2012 04:20 PM, Shawn Joo wrote:
> Dear Experts,
>=20
> =20
>=20
> I would like to know a mechanism, how to increase the number of object =

> and where the memory is from.
>=20
> (because when cache is created by "kmem_cache_create", there is only=20
> object size, but no number of the object)
>=20
> For example, "size-65536" does not have available memory from below dum=
p.
>=20
> In that state, if memory allocation is requested to "size-65536",
>=20
> 1.     How to allocate/increase the number of object on "size-65536"?
>=20
> 2.     Where is the new allocated memory from? (from buddy?)
>=20
> =20

I am not sure I fully understand your question. But if you refer to somet=
hing like "from where does the object allocators get their memory when mo=
re is needed", then yes, they will allocate the necessary number of pages=
=20from the standard page allocator.

-------------------------------------------------------------------------=
----------
This email message is for the sole use of the intended recipient(s) and m=
ay contain
confidential information.  Any unauthorized review, use, disclosure or di=
stribution
is prohibited.  If you are not the intended recipient, please contact the=
=20sender by
reply email and destroy all copies of the original message.
-------------------------------------------------------------------------=
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
