Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 340F06B0255
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 10:04:01 -0500 (EST)
Received: by wmec201 with SMTP id c201so73997864wme.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:04:00 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id x130si11041095wmx.46.2015.11.27.07.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 07:04:00 -0800 (PST)
Received: by wmuu63 with SMTP id u63so58696713wmu.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:03:59 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm/compaction: improve comment for compact_memory tunable knob handler
In-Reply-To: <1448442448-3268-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1448442448-3268-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Date: Fri, 27 Nov 2015 16:03:57 +0100
Message-ID: <xa1tzixz1o2q.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>, akpm@linux-foundation.org
Cc: vbabka@suse.cz, iamjoonsoo.kim@lge.com, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 25 2015, Yaowei Bai wrote:
> Sysctl_compaction_handler() is the handler function for compact_memory
> tunable knob under /proc/sys/vm, add the missing knob name to make this
> more accurate in comment.
>
> No functional change.
>
> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>

Since I'm explicitly on CC, I might just as well:

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/compaction.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index de3e1e7..ac6c694 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1708,7 +1708,10 @@ static void compact_nodes(void)
>  /* The written value is actually unused, all memory is compacted */
>  int sysctl_compact_memory;
>=20=20
> -/* This is the entry point for compacting all nodes via /proc/sys/vm */
> +/*
> + * This is the entry point for compacting all nodes via
> + * /proc/sys/vm/compact_memory
> + */
>  int sysctl_compaction_handler(struct ctl_table *table, int write,
>  			void __user *buffer, size_t *length, loff_t *ppos)
>  {
> --=20
> 1.9.1
>
>
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  =E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9Cmina86=E2=80=
=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=84  (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
