Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 920D46B006E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:59:00 -0400 (EDT)
Date: Tue, 4 Sep 2012 22:58:59 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: C13 [05/14] Extract a common function for kmem_cache_destroy
In-Reply-To: <5044CC24.7000800@parallels.com>
Message-ID: <00000139938213ef-f5749497-9038-4275-9aaa-bb6b08f54dec-000000@email.amazonses.com>
References: <20120824160903.168122683@linux.com> <000001395965f8f6-7ff20b9e-f748-4af4-a3c9-a9684022361f-000000@email.amazonses.com> <5044CC24.7000800@parallels.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="288502408-323154704-1346799548=:30174"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--288502408-323154704-1346799548=:30174
Content-Type: TEXT/PLAIN; charset=windows-1252
Content-Transfer-Encoding: 8BIT

On Mon, 3 Sep 2012, Glauber Costa wrote:

> On 08/24/2012 08:10 PM, Christoph Lameter wrote:
> > kmem_cache_destroy does basically the same in all allocators.
> >
> > Extract common code which is easy since we already have common mutex handling.
> >
> > V1-V2:
> > 	- Move percpu freeing to later so that we fail cleaner if
> > 		objects are left in the cache [JoonSoo Kim]
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Fails to build for the slab. Error is pretty much self-explanatory:
>
>   CC      mm/slab.o
> mm/slab.c: In function i? 1/2 slab_destroy_debugchecki? 1/2 :
> mm/slab.c:2157:5: error: implicit declaration of function i? 1/2 slab_errori? 1/2 
> [-Werror=implicit-function-declaration]

Ok. We need to keep the slab_error function for now.

--288502408-323154704-1346799548=:30174--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
