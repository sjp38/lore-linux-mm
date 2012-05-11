Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id EB1036B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 20:04:21 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d8fb8c73-0fd4-47c6-a9bb-ba3573569d63@default>
Date: Thu, 10 May 2012 17:03:57 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
References: <1336027242-372-1-git-send-email-minchan@kernel.org>
 <1336027242-372-4-git-send-email-minchan@kernel.org>
 <4FA28EFD.5070002@vflare.org> <4FA33E89.6080206@kernel.org>
 <alpine.LFD.2.02.1205071038090.2851@tux.localdomain>
 <4FA7C2BC.2090400@vflare.org> <4FA87837.3050208@kernel.org>
 <731b6638-8c8c-4381-a00f-4ecd5a0e91ae@default> <4FA9C127.5020908@kernel.org>
In-Reply-To: <4FA9C127.5020908@kernel.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: Re: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
>=20
> On 05/08/2012 11:00 PM, Dan Magenheimer wrote:
>=20
> >> From: Minchan Kim [mailto:minchan@kernel.org]
> >>> zcache can potentially create a lot of pools, so the latter will save
> >>> some memory.
> >>
> >>
> >> Dumb question.
> >> Why should we create pool per user?
> >> What's the problem if there is only one pool in system?
> >
> > zcache doesn't use zsmalloc for cleancache pages today, but
> > that's Seth's plan for the future.  Then if there is a
> > separate pool for each cleancache pool, when a filesystem
> > is umount'ed, it isn't necessary to walk through and delete
> > all pages one-by-one, which could take quite awhile.
>=20
> >
>=20
> > ramster needs one pool for each client (i.e. machine in the
> > cluster) for frontswap pages for the same reason, and
> > later, for cleancache pages, one per mounted filesystem
> > per client
>=20
>=20
> Fair enough.
> But some subsystems can't want a own pool for not waste unnecessary memor=
y.
>=20
> Then, how about this interfaces like slab?
>=20
> 1. zs_handle zs_malloc(size_t size, gfp_t flags) - share a pool by many s=
ubsystem(like kmalloc)
> 2. zs_handle zs_malloc_pool(struct zs_pool *pool, size_t size) - use own =
pool(like kmem_cache_alloc)
>=20
> Any thoughts?

I don't have any objections to adding this kind of
capability to zsmalloc.  But since we are just speculating
that this capability would be used by some future
kernel subsystem, isn't it normal kernel protocol for
this new capability NOT to be added until that future
kernel subsystem creates a need for it.

As I said in reply to the other thread, there is missing
functionality in zsmalloc that is making it difficult for
it to be used by zcache.  It would be good if Seth
and Nitin (and any other kernel developers) would work
on those issues before adding capabilities for non-existent
future users of zsmalloc.

Again, that's just my opinion.
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
