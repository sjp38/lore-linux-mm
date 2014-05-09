Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 58F416B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:49:44 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so400948pad.25
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:49:44 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id ot9si2235215pac.53.2014.05.09.08.49.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 08:49:43 -0700 (PDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so3838298pdj.39
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:49:43 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 2/2] mm/compaction: avoid rescanning pageblocks in isolate_freepages
In-Reply-To: <1399464550-26447-2-git-send-email-vbabka@suse.cz>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com> <1399464550-26447-1-git-send-email-vbabka@suse.cz> <1399464550-26447-2-git-send-email-vbabka@suse.cz>
Date: Fri, 09 May 2014 08:49:35 -0700
Message-ID: <xa1ttx8zvto0.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, May 07 2014, Vlastimil Babka wrote:
> The compaction free scanner in isolate_freepages() currently remembers PF=
N of
> the highest pageblock where it successfully isolates, to be used as the
> starting pageblock for the next invocation. The rationale behind this is =
that
> page migration might return free pages to the allocator when migration fa=
ils
> and we don't want to skip them if the compaction continues.
>
> Since migration now returns free pages back to compaction code where they=
 can
> be reused, this is no longer a concern. This patch changes isolate_freepa=
ges()
> so that the PFN for restarting is updated with each pageblock where isola=
tion
> is attempted. Using stress-highalloc from mmtests, this resulted in 10%
> reduction of the pages scanned by the free scanner.
>
> Note that the somewhat similar functionality that records highest success=
ful
> pageblock in zone->compact_cached_free_pfn, remains unchanged. This cache=
 is
> used when the whole compaction is restarted, not for multiple invocations=
 of
> the free scanner during single compaction.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  v2: no changes, just keep patches together
>
>  mm/compaction.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
>
--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJTbPkPAAoJECBgQBJQdR/0RLcP/0AAvkxxjS2riJKTHRTWd/aJ
2aiLce1bXE7jeZ9w86p5jJzdh0WygXTw4gUgv53JVo2qj6oBlb6r4uwS3tsn+CeU
oK7EpLbCHJ2KzzTjMr662xwogg/8NPsdvMY+phghebfdTFxl+SYUm5yvHi2zsJRZ
enO+Rei9gZnZLi2AQiBPi/qVnjeu2pkIm2ty99G2GWpqi4uKfWy6U595jkuPnYhr
sG0ptclWFM9JJ12DfPerbiZFddq/wmFQJaLVEBcrLO0GiHpJ2KK4inKC5jP1R5uu
KcBXFc8Lm907PElA1Mqe2NjALbVpfN4+n0/M1Ye8ZL74yzy68CZCLueHAWw+m+Ia
399uKqUzW3xdNFzJ2tcZApdpjsWg2MHr3ilFSvpejS+i4tgMJeiWszQ7ZKx6zTHd
5lZH6Jd5NC4mENrfb8o5Vs2ghOCp3t0+o6EN/x/AMAsW/uWFYtWvCxDwmAdAjRpY
CVCbf236O1DP7s9xH4kWUxPcd/bVUJGT1fhSHTxUioEi18Qnd3hma+GcBbStIw2M
tqeoC5kS50ExKhVmg3WVAI0FC/uphdugt+kBV6Q+K05zfXQyp1dTgO/yqjbsxqCK
h+TcGctFLeNPQfpUtUcgc/wVnrcUuFZArU1CyZPLPDfWFI3jNVzHY9Wq26QxZ5hE
wUwzCQZK4DWaEFuc6CA6
=d7uz
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
