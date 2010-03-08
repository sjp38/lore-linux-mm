Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AB7816B00A9
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 08:29:18 -0500 (EST)
Received: by fxm8 with SMTP id 8so6103831fxm.11
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 05:29:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
Date: Mon, 8 Mar 2010 15:29:16 +0200
Message-ID: <84144f021003080529w1b20c08dmf6871bd46381bc71@mail.gmail.com>
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 8, 2010 at 11:21 AM, Thomas Gleixner <tglx@linutronix.de> wrote=
:
> __zone_pcp_update() iterates over NR_CPUS instead of limiting the
> access to the possible cpus. This might result in access to
> uninitialized areas as the per cpu allocator only populates the per
> cpu memory for possible cpus.
>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Looks OK to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
> =A0mm/page_alloc.c | =A0 =A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: linux-2.6/mm/page_alloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -3224,7 +3224,7 @@ static int __zone_pcp_update(void *data)
> =A0 =A0 =A0 =A0int cpu;
> =A0 =A0 =A0 =A0unsigned long batch =3D zone_batchsize(zone), flags;
>
> - =A0 =A0 =A0 for (cpu =3D 0; cpu < NR_CPUS; cpu++) {
> + =A0 =A0 =A0 for_each_possible_cpu(cpu) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct per_cpu_pageset *pset;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct per_cpu_pages *pcp;
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
