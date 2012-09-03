Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 292476B005D
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:29:40 -0400 (EDT)
Message-ID: <5044CC24.7000800@parallels.com>
Date: Mon, 3 Sep 2012 19:26:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [05/14] Extract a common function for kmem_cache_destroy
References: <20120824160903.168122683@linux.com> <000001395965f8f6-7ff20b9e-f748-4af4-a3c9-a9684022361f-000000@email.amazonses.com>
In-Reply-To: <000001395965f8f6-7ff20b9e-f748-4af4-a3c9-a9684022361f-000000@email.amazonses.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:10 PM, Christoph Lameter wrote:
> kmem_cache_destroy does basically the same in all allocators.
>=20
> Extract common code which is easy since we already have common mutex hand=
ling.
>=20
> V1-V2:
> 	- Move percpu freeing to later so that we fail cleaner if
> 		objects are left in the cache [JoonSoo Kim]
>=20
> Signed-off-by: Christoph Lameter <cl@linux.com>

Fails to build for the slab. Error is pretty much self-explanatory:

  CC      mm/slab.o
mm/slab.c: In function =91slab_destroy_debugcheck=92:
mm/slab.c:2157:5: error: implicit declaration of function =91slab_error=92
[-Werror=3Dimplicit-function-declaration]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
