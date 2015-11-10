Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id AC5A26B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:59:00 -0500 (EST)
Received: by wmvv187 with SMTP id v187so15066649wmv.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:59:00 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id m6si5249699wjz.192.2015.11.10.07.58.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 07:58:59 -0800 (PST)
Received: by wmww144 with SMTP id w144so6719200wmw.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:58:59 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] mm: introduce page reference manipulation functions
In-Reply-To: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 10 Nov 2015 16:58:56 +0100
Message-ID: <xa1th9ktg81r.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Nov 09 2015, Joonsoo Kim wrote:
> Success of CMA allocation largely depends on success of migration
> and key factor of it is page reference count. Until now, page reference
> is manipulated by direct calling atomic functions so we cannot follow up
> who and where manipulate it. Then, it is hard to find actual reason
> of CMA allocation failure. CMA allocation should be guaranteed to succeed
> so finding offending place is really important.
>
> In this patch, call sites where page reference is manipulated are convert=
ed
> to introduced wrapper function. This is preparation step to add tracepoint
> to each page reference manipulation function. With this facility, we can
> easily find reason of CMA allocation failure. There is no functional chan=
ge
> in this patch.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  arch/mips/mm/gup.c                                |  2 +-
>  arch/powerpc/mm/mmu_context_hash64.c              |  3 +-
>  arch/powerpc/mm/pgtable_64.c                      |  2 +-
>  arch/x86/mm/gup.c                                 |  2 +-
>  drivers/block/aoe/aoecmd.c                        |  4 +-
>  drivers/net/ethernet/freescale/gianfar.c          |  2 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c     |  2 +-
>  drivers/net/ethernet/intel/igb/igb_main.c         |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  2 +-
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c        |  7 +--
>  drivers/net/ethernet/sun/niu.c                    |  2 +-
>  include/linux/mm.h                                | 21 ++-----
>  include/linux/page_ref.h                          | 76 +++++++++++++++++=
++++++
>  include/linux/pagemap.h                           | 19 +-----
>  mm/huge_memory.c                                  |  6 +-
>  mm/internal.h                                     |  5 --
>  mm/memory_hotplug.c                               |  4 +-
>  mm/migrate.c                                      | 10 +--
>  mm/page_alloc.c                                   |  6 +-
>  mm/vmscan.c                                       |  6 +-
>  21 files changed, 114 insertions(+), 71 deletions(-)
>  create mode 100644 include/linux/page_ref.h
>

--=20
Best regards,                                            _     _
.o. | Liege of Serenely Enlightened Majesty of         o' \,=3D./ `o
..o | Computer Science,  =E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9Cmina86=E2=80=
=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=84  (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
