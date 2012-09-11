Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 484BA6B00C1
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 07:16:05 -0400 (EDT)
Received: by weys10 with SMTP id s10so293955wey.14
        for <linux-mm@kvack.org>; Tue, 11 Sep 2012 04:16:03 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: Discard clean pages during contiguous allocation instead of migration
In-Reply-To: <1347324112-14134-1-git-send-email-minchan@kernel.org>
References: <1347324112-14134-1-git-send-email-minchan@kernel.org>
Date: Tue, 11 Sep 2012 13:15:56 +0200
Message-ID: <xa1tehm8yfmb.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kmpark@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On Tue, Sep 11 2012, Minchan Kim wrote:
> This patch drops clean cache pages instead of migration during
> alloc_contig_range() to minimise allocation latency by reducing the amount
> of migration is necessary. It's useful for CMA because latency of migrati=
on
> is more important than evicting the background processes working set.
> In addition, as pages are reclaimed then fewer free pages for migration
> targets are required so it avoids memory reclaiming to get free pages,
> which is a contributory factor to increased latency.
>
> * from v1
>   * drop migrate_mode_t
>   * add reclaim_clean_pages_from_list instad of MIGRATE_DISCARD support -=
 Mel
>
> I measured elapsed time of __alloc_contig_migrate_range which migrates
> 10M in 40M movable zone in QEMU machine.
>
> Before - 146ms, After - 7ms
>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

Thanks!

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQTx1sAAoJECBgQBJQdR/0rcAP/34tPp7PJzehiwRqe7xBd/7W
dmjRpYfGP08EvaxUgxPRdC/EAZTpgBy/jsVoa1vEXc1rAM3pCwKR3L5cTFd8xc4o
/mKYzWAQy3N9zF/VrZiicZqLoguZJs9jqQoyqY9sO8qaMYqzQ92ETof1gsIGAv7J
tx4UlECDu1tQrp9cDSMcP97Z1JnMh3hJ2V1cLrouW4nuQBCcImF3eR5NdEM84pEC
rhBCmonm2X7SwPWkmc7tWXOEiqT3h9O7WGOl8Qc2JFDINVYXsGJFCwUC1LRIHqOt
zFjwOmOeOdrqog6Wf2hRY7LpCzSjWsmz6MP747dJOZxlv+cdocIF6ibj6ZgoHjJj
Ced0baWmH7fi963o9czgwO6JGeQ5swS06b+etFTwurQaRqNYc7nXhMoMZppaFuRq
kEEfTbf2fkRONVoaWhUI7smSt7HH4zAjKlfN1YTXCy/fey2B37X7tBhQZsrGGwvm
xn1zPXnxcrffu6L8afiPHqswFZCLX+Ta8KdPQvQP2ir23WPZ3P5f9VBt9e77uYng
gu+2u8+zIalS9OPfZiUI2VB/xfR5TdR1HJZQHU4Xl/KzcWiQyjrKWamjnh3nxRfg
G7BfNuwhZVnM+vDzjc+DHr56uJnxEAf9NMnKv6a9gXZRQHdI4QiImkAnZfhNtjSl
/zy9TV9nwTkRcYhbKOHq
=C9Mk
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
