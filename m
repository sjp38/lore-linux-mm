Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id EAEAF82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 16:29:40 -0500 (EST)
Received: by igvi2 with SMTP id i2so99074528igv.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 13:29:40 -0800 (PST)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id 84si3812001ioh.110.2015.11.04.13.29.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 13:29:40 -0800 (PST)
Received: by iodd200 with SMTP id d200so68888623iod.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 13:29:40 -0800 (PST)
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <20151104200006.GA46783@kernel.org> <563A7591.7080607@gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <563A789C.5040409@gmail.com>
Date: Wed, 4 Nov 2015 16:29:00 -0500
MIME-Version: 1.0
In-Reply-To: <563A7591.7080607@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="uKBOvN247j2AhpxbKS9KA7xPxPb947xqX"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, bmaurer@fb.com

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uKBOvN247j2AhpxbKS9KA7xPxPb947xqX
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

> That's comparable to Android's pinning / unpinning API for ashmem and I=

> think it makes sense if it's faster. It's different than the MADV_FREE
> API though, because the new allocations that are handed out won't have
> the usual lazy commit which MADV_FREE provides. Pages in an allocation
> that's handed out can still be dropped until they are actually written
> to. It's considered active by jemalloc either way, but only a subset of=

> the active pages are actually committed. There's probably a use case fo=
r
> both of these systems.

Also, consider that MADV_FREE would allow jemalloc to be extremely
aggressive with purging when it actually has to do it. It can start with
the largest span of memory and it can mark more than strictly necessary
to drop below the ratio as there's no cost to using the memory again
(not even a system call).

Since the main cost is using the system call at all, there's going to be
pressure to mark the largest possible spans in one go. It will mean
concentration on memory compaction will improve performance. I think
that's the right direction for the kernel to be guiding userspace. It
will play better with THP than the allocator trying to be very precise
with purging based on aging.


--uKBOvN247j2AhpxbKS9KA7xPxPb947xqX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOnicAAoJEPnnEuWa9fIqPygP/34m87CX/U7dqygXAt2utvmi
sqX36PHbkm9mScLW7iin77VBJz+o/oVHqaEHryN14t+bVrDm/n7o4jaJKCDpJxm6
W9OoeF65SRXI95GoyDnvgZ5TvMuBwf9AGK36mahPMjlWkIka1KbUyd5Dy7GaFOKL
kSc6ETZK2SnHeOD0bTUk33I78pIJWJxk040CzDYfDwNuVs7fwD9rW2TbSfV8Inkm
9FN7GUKY8IHznLr/BV9wDlVd9CDvH/vaPdhc2f5SKtICnEiv6ZUUhCDmx2oHwlUC
NGPXIBVLn1iOeeGAbUb3oFz/1Tua92eDpYr/xwoPk75X+Wzi3GvUFKZ7HWH4EcP0
FC3FNwp/Ig1IC4BjoY8/kAiQS3PX+iTB5TGCdZmIpP2Y/W32lnoj7cdve/EHaJh/
4PFOmKxqSBgxG/DMTM+W4skov/c5LUcDt4BBLC14nEYqc9yN73HaFuprcwKHqbSN
p0TuvXK90r22XgH/jJ2EjeGjEG2Vyjj1UYdl1OWVBYXHO8aWqVzR+GQ8IFzBNk/i
Ip2571ITaUXsKFo6DJTquKJq1r6jvmH8TjI/hqZUq0Cogog+R2KMVobJUwGa/MoV
TDyrpWrdtqux/B7yjBqQcO2m3WwFyXIqMPZ2q9bS0bo8uyNQ2z7vxPfhQP+62Tng
O2ZV6Slyha4JAr2Ueubi
=Mp2Q
-----END PGP SIGNATURE-----

--uKBOvN247j2AhpxbKS9KA7xPxPb947xqX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
