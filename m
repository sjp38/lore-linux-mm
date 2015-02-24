Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D8C3A6B0071
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:14:53 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id bs8so462228wib.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:14:53 -0800 (PST)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id hs6si69516341wjb.68.2015.02.24.13.14.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 13:14:52 -0800 (PST)
Received: by wggy19 with SMTP id y19so8000237wgg.10
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:14:52 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v3 1/4] mm: cma: add trace events to debug physically-contiguous memory allocations
In-Reply-To: <9ae4c45b49e8df6e079448550c2b81ade5d3603a.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com> <9ae4c45b49e8df6e079448550c2b81ade5d3603a.1424802755.git.s.strogin@partner.samsung.com>
Date: Tue, 24 Feb 2015 22:14:48 +0100
Message-ID: <xa1ttwybovuf.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Tue, Feb 24 2015, Stefan Strogin <s.strogin@partner.samsung.com> wrote:
> Add trace events for cma_alloc() and cma_release().
>
> Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>

Looks good to me but than again I don=E2=80=99t know much about trace point=
s so
perhaps someone else should ack it as well.

> ---
>  include/trace/events/cma.h | 57 ++++++++++++++++++++++++++++++++++++++++=
++++++
>  mm/cma.c                   |  6 +++++
>  2 files changed, 63 insertions(+)
>  create mode 100644 include/trace/events/cma.h

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
