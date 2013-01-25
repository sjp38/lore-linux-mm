Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 5540C6B0009
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:33:21 -0500 (EST)
MIME-Version: 1.0
Message-ID: <1e053fad-6536-4f8f-9944-1703916c62dd@default>
Date: Fri, 25 Jan 2013 15:33:14 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] staging: zsmalloc: various cleanups/improvments
References: <<1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: [PATCH 0/4] staging: zsmalloc: various cleanups/improvments
>=20
> These patches are the first 4 patches of the zswap patchset I
> sent out previously.  Some recent commits to zsmalloc and
> zcache in staging-next forced a rebase. While I was at it, Nitin
> (zsmalloc maintainer) requested I break these 4 patches out from
> the zswap patchset, since they stand on their own.
>=20
> All are already Acked-by Nitin.
>=20
> Based on staging-next as of today.
>=20
> Seth Jennings (4):
>   staging: zsmalloc: add gfp flags to zs_create_pool
>   staging: zsmalloc: remove unused pool name
>   staging: zsmalloc: add page alloc/free callbacks
>   staging: zsmalloc: make CLASS_DELTA relative to PAGE_SIZE
>=20
>  drivers/staging/zram/zram_drv.c          |    4 +-
>  drivers/staging/zsmalloc/zsmalloc-main.c |   60 ++++++++++++++++++------=
------
>  drivers/staging/zsmalloc/zsmalloc.h      |   10 ++++-
>  3 files changed, 47 insertions(+), 27 deletions(-)

FWIW, please add my ack to all the patches.  I'm happy
to see zsmalloc move forward.   I'm a bit skeptical
that it will ever be capable of doing everything we
would like it to do, but am eager to see if it can.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
