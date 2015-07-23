Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id ED3266B0260
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 02:51:45 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so80455392pab.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 23:51:45 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id r14si9642378pdi.86.2015.07.22.23.51.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 23:51:45 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] mm: rename and move get/set_freepage_migratetype
Date: Thu, 23 Jul 2015 06:48:08 +0000
Message-ID: <20150723064806.GC16668@hori1.linux.bs1.fc.nec.co.jp>
References: <55969822.9060907@suse.cz>
 <1437483218-18703-1-git-send-email-vbabka@suse.cz>
 <1437483218-18703-2-git-send-email-vbabka@suse.cz> <55AF8C94.6020406@suse.cz>
In-Reply-To: <55AF8C94.6020406@suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7C22623600D23D4DA44DC07E854D4946@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minkyung88.kim" <minkyung88.kim@lge.com>, "kmk3210@gmail.com" <kmk3210@gmail.com>, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Jul 22, 2015 at 02:29:08PM +0200, Vlastimil Babka wrote:
> On 07/21/2015 02:53 PM, Vlastimil Babka wrote:
> > The pair of get/set_freepage_migratetype() functions are used to cache
> > pageblock migratetype for a page put on a pcplist, so that it does not =
have
> > to be retrieved again when the page is put on a free list (e.g. when pc=
plists
> > become full). Historically it was also assumed that the value is accura=
te for
> > pages on freelists (as the functions' names unfortunately suggest), but=
 that
> > cannot be guaranteed without affecting various allocator fast paths. It=
 is in
> > fact not needed and all such uses have been removed.
> >=20
> > The last remaining (but pointless) usage related to pages of freelists =
is in
> > move_freepages(), which this patch removes.
>=20
> I realized there's one more callsite that can be removed. Here's
> whole updated patch due to different changelog and to cope with
> context changed by the fixlet to patch 1/2.
>=20
> ------8<------
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 2 Jul 2015 16:37:06 +0200
> Subject: mm: rename and move get/set_freepage_migratetype
>=20
> The pair of get/set_freepage_migratetype() functions are used to cache
> pageblock migratetype for a page put on a pcplist, so that it does not ha=
ve
> to be retrieved again when the page is put on a free list (e.g. when pcpl=
ists
> become full). Historically it was also assumed that the value is accurate=
 for
> pages on freelists (as the functions' names unfortunately suggest), but t=
hat
> cannot be guaranteed without affecting various allocator fast paths. It i=
s in
> fact not needed and all such uses have been removed.
>=20
> The last two remaining (but pointless) usages related to pages of freelis=
ts
> are removed by this patch:
> - move_freepages() which operates on pages already on freelists
> - __free_pages_ok() which puts a page directly to freelist, bypassing pcp=
lists
>=20
> To prevent further confusion, rename the functions to
> get/set_pcppage_migratetype() and expand their description. Since all the
> users are now in mm/page_alloc.c, move the functions there from the share=
d
> header.
>=20
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Laura Abbott <lauraa@codeaurora.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
