Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id E63C46B0074
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:19:26 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id v1so3500335yhn.15
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:19:26 -0700 (PDT)
Received: from fujitsu24.fnanic.fujitsu.com (fujitsu24.fnanic.fujitsu.com. [192.240.6.14])
        by mx.google.com with ESMTPS id v6si33982917yhm.170.2014.04.22.13.19.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 13:19:26 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Tue, 22 Apr 2014 13:17:15 -0700
Subject: RE: [PATCH 4/4] ipc/shm.c: Increase the defaults for SHMALL, SHMMAX.
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E30989E9D84@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
 <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
 <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
 <1398090397-2397-4-git-send-email-manfred@colorfullife.com>
 <1398090397-2397-5-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1398090397-2397-5-git-send-email-manfred@colorfullife.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "gthelen@google.com" <gthelen@google.com>, "aswin@hp.com" <aswin@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: Manfred Spraul [mailto:manfred@colorfullife.com]
> Sent: Monday, April 21, 2014 10:27 AM
> To: Davidlohr Bueso; Michael Kerrisk; Martin Schwidefsky
> Cc: LKML; Andrew Morton; KAMEZAWA Hiroyuki; Motohiro Kosaki JP; gthelen@g=
oogle.com; aswin@hp.com; linux-mm@kvack.org;
> Manfred Spraul
> Subject: [PATCH 4/4] ipc/shm.c: Increase the defaults for SHMALL, SHMMAX.
>=20
> System V shared memory
>=20
> a) can be abused to trigger out-of-memory conditions and the standard
>    measures against out-of-memory do not work:
>=20
>     - it is not possible to use setrlimit to limit the size of shm segmen=
ts.
>=20
>     - segments can exist without association with any processes, thus
>       the oom-killer is unable to free that memory.
>=20
> b) is typically used for shared information - today often multiple GB.
>    (e.g. database shared buffers)
>=20
> The current default is a maximum segment size of 32 MB and a maximum tota=
l size of 8 GB. This is often too much for a) and not
> enough for b), which means that lots of users must change the defaults.
>=20
> This patch increases the default limits (nearly) to the maximum, which is=
 perfect for case b). The defaults are used after boot and as
> the initial value for each new namespace.
>=20
> Admins/distros that need a protection against a) should reduce the limits=
 and/or enable shm_rmid_forced.
>=20
> Further notes:
> - The patch only changes default, overrides behave as before:
>         # sysctl kernel.shmall=3D33554432
>   would recreate the previous limit for SHMMAX (for the current namespace=
).
>=20
> - Disabling sysv shm allocation is possible with:
>         # sysctl kernel.shmall=3D0
>   (not a new feature, also per-namespace)
>=20
> - The limits are intentionally set to a value slightly less than ULONG_MA=
X,
>   to avoid triggering overflows in user space apps.
>   [not unreasonable, see http://marc.info/?l=3Dlinux-mm&m=3D1396383343301=
27]
>=20
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> Reported-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: mtk.manpages@gmail.com

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
