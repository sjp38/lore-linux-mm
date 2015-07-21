Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 763E86B02D4
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 04:36:10 -0400 (EDT)
Received: by obnw1 with SMTP id w1so114467154obn.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:36:10 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id v69si18247700oif.139.2015.07.21.01.36.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 01:36:09 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 5/5] pagemap: add mmap-exclusive bit for marking
 pages mapped only here
Date: Tue, 21 Jul 2015 08:17:56 +0000
Message-ID: <20150721081755.GD4490@hori1.linux.bs1.fc.nec.co.jp>
References: <20150714152516.29844.69929.stgit@buzz>
 <20150714153749.29844.81954.stgit@buzz>
In-Reply-To: <20150714153749.29844.81954.stgit@buzz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <26C19608054104418F64BD8DB1EFF9D9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>

On Tue, Jul 14, 2015 at 06:37:49PM +0300, Konstantin Khlebnikov wrote:
> This patch sets bit 56 in pagemap if this page is mapped only once.
> It allows to detect exclusively used pages without exposing PFN:
>=20
> present file exclusive state
> 0       0    0         non-present
> 1       1    0         file page mapped somewhere else
> 1       1    1         file page mapped only here
> 1       0    0         anon non-CoWed page (shared with parent/child)
> 1       0    1         anon CoWed page (or never forked)
>=20
> CoWed pages in (MAP_FILE | MAP_PRIVATE) areas are anon in this context.
>=20
> MMap-exclusive bit doesn't reflect potential page-sharing via swapcache:
> page could be mapped once but has several swap-ptes which point to it.
> Application could detect that by swap bit in pagemap entry and touch
> that pte via /proc/pid/mem to get real information.
>=20
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Requested-by: Mark Williamson <mwilliamson@undo-software.com>
> Link: http://lkml.kernel.org/r/CAEVpBa+_RyACkhODZrRvQLs80iy0sqpdrd0AaP_-t=
gnX3Y9yNQ@mail.gmail.com

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
