Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id D1E016B0073
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:26:44 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <1b8baea8-531a-45a0-b490-4a2ac5c64784@default>
Date: Mon, 29 Oct 2012 08:25:07 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v3 0/3] zram/zsmalloc promotion
References: <<1351501009-15111-1-git-send-email-minchan@kernel.org>>
In-Reply-To: <<1351501009-15111-1-git-send-email-minchan@kernel.org>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jens Axboe <axboe@kernel.dk>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: [PATCH v3 0/3] zram/zsmalloc promotion
>=20
> The candidate is two under mm/ or under lib/
> Konrad and Nitin wanted to put zsmalloc into lib/ instead of mm/.
>=20
> Quote from Nitin
> "
> I think mm/ directory should only contain the code which is intended
> for global use such as the slab allocator, page reclaim code etc.
> zsmalloc is used by only one (or possibly two) drivers, so lib/ seems
> to be the right place.
> "
>=20
> Quote from Konrand
> "
> I like the idea of keeping it in /lib or /mm. Actually 'lib' sounds more
> appropriate since it is dealing with storing a bunch of pages in a nice
> layout for great density purposes.
> "
>=20
> In fact, there is some history about that.
>=20
> Why I put zsmalloc into under mm firstly was that Andrew had a concern
> about using strut page's some fields freely in zsmalloc so he wanted
> to maintain it in mm/ if I remember correctly.
>=20
> So I and Nitin tried to ask the opinion to akpm several times
> (at least 6 and even I sent such patch a few month ago) but didn't get
> any reply from him so I guess he doesn't have any concern about that
> any more.
>=20
> In point of view that it's an another slab-like allocator,
> it might be proper under mm but it's not popular as current mm's
> allocators(/SLUB/SLOB and page allocator).
>=20
> Frankly speaking, I don't care whether we put it to mm/ or lib/.
> It seems contributors(ex, Nitin and Konrad) like lib/ and Andrew is still
> silent. That's why I am biased into lib/ now.
>=20
> If someone yell we should keep it to mm/ by logical claim, I can change
> my mind easily. Please raise your hand.
>=20
> If Andrew doesn't have a concern about that any more, I would like to
> locate it into /lib.

FWIW, I would vote for /lib as well.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
