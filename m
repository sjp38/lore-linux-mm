Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7086B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:34:41 -0500 (EST)
Received: by wevk48 with SMTP id k48so27964113wev.0
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:34:40 -0800 (PST)
Received: from mail-we0-x229.google.com (mail-we0-x229.google.com. [2a00:1450:400c:c03::229])
        by mx.google.com with ESMTPS id jf15si25492163wic.122.2015.02.24.13.34.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 13:34:39 -0800 (PST)
Received: by wevm14 with SMTP id m14so27914390wev.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:34:38 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v3 4/4] mm: cma: add functions to get region pages counters
In-Reply-To: <39c295d8354268391d62904ec57626596c835d34.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com> <39c295d8354268391d62904ec57626596c835d34.1424802755.git.s.strogin@partner.samsung.com>
Date: Tue, 24 Feb 2015 22:34:35 +0100
Message-ID: <xa1tlhjnouxg.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Tue, Feb 24 2015, Stefan Strogin <s.strogin@partner.samsung.com> wrote:
> From: Dmitry Safonov <d.safonov@partner.samsung.com>
>
> Here are two functions that provide interface to compute/get used size
> and size of biggest free chunk in cma region. Add that information to deb=
ugfs.
>
> Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
> Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  include/linux/cma.h |  2 ++
>  mm/cma.c            | 30 ++++++++++++++++++++++++++++++
>  mm/cma_debug.c      | 24 ++++++++++++++++++++++++
>  3 files changed, 56 insertions(+)

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
