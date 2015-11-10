Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 072F36B0257
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 11:06:37 -0500 (EST)
Received: by wmww144 with SMTP id w144so7040486wmw.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:06:36 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id v12si5341285wjr.84.2015.11.10.08.06.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 08:06:35 -0800 (PST)
Received: by wmww144 with SMTP id w144so7039248wmw.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:06:35 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/3] mm/cma: add new tracepoint, test_pages_isolated
In-Reply-To: <1447053861-28824-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com> <1447053861-28824-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 10 Nov 2015 17:06:31 +0100
Message-ID: <xa1t8u65g7p4.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Nov 09 2015, Joonsoo Kim wrote:
> cma allocation should be guranteeded to succeed, but, sometimes,
> it could be failed in current implementation. To track down
> the problem, we need to know which page is problematic and
> this new tracepoint will report it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I=E2=80=99m not really familiar with tracing framework but other then that:

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  include/trace/events/cma.h | 26 ++++++++++++++++++++++++++
>  mm/page_isolation.c        |  5 +++++
>  2 files changed, 31 insertions(+)

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
