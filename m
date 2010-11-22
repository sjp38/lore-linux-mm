Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 614736B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 04:00:30 -0500 (EST)
From: "Kleen, Andi" <andi.kleen@intel.com>
Date: Mon, 22 Nov 2010 08:59:57 +0000
Subject: RE: [PATCH 0/4] big chunk memory allocator v4
Message-ID: <F4DF93C7785E2549970341072BC32CD796018FCB@irsmsx503.ger.corp.intel.com>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
 <20101119125653.16dd5452.akpm@linux-foundation.org>
In-Reply-To: <20101119125653.16dd5452.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Bob Liu <lliubbo@gmail.com>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "m.nazarewicz@samsung.com" <m.nazarewicz@samsung.com>, "pawel@osciak.com" <pawel@osciak.com>, "felipe.contreras@gmail.com" <felipe.contreras@gmail.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> >   But yes, because of fragmentation, this cannot guarantee 100%
> alloc.
> >   If alloc_contig_pages() is called in system boot up or movable_zone
> is used,
> >   this allocation succeeds at high rate.
>=20
> So this is an alternatve implementation for the functionality offered
> by Michal's "The Contiguous Memory Allocator framework".

I see them more as orthogonal: Michal's code relies on preallocation
and manages the memory after that.

This code supplies the infrastructure to replace preallocation
with just using movable zones.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
