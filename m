Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 954666B4ABA
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 23:24:38 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so11361500pgv.23
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 20:24:38 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f35si6143578plh.399.2018.11.27.20.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 20:24:37 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] Small typo fix
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181127210459.11809-1-ates@bu.edu>
Date: Tue, 27 Nov 2018 21:24:22 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <5740EF93-84C7-4234-B6F3-2D55271F06B1@oracle.com>
References: <20181127210459.11809-1-ates@bu.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emre Ates <ates@bu.edu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Nov 27, 2018, at 2:04 PM, Emre Ates <ates@bu.edu> wrote:
>=20
> ---
> mm/vmstat.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 9c624595e904..cc7d04928c2e 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1106,7 +1106,7 @@ int fragmentation_index(struct zone *zone, =
unsigned int order)
> 					TEXT_FOR_HIGHMEM(xx) xx =
"_movable",
>=20
> const char * const vmstat_text[] =3D {
> -	/* enum zone_stat_item countes */
> +	/* enum zone_stat_item counters */
> 	"nr_free_pages",
> 	"nr_zone_inactive_anon",
> 	"nr_zone_active_anon",
> --
> 2.19.1
>=20
> Signed-off-by: Emre Ates <ates@bu.edu>

Reviewed-by: William Kucharski <william.kucharski@oracle.com>
