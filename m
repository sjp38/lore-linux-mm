Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5EEE06B012A
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 02:09:44 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2390202bwz.38
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 23:09:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <_yaHeGjHEzG.A.FIH.7sGlKB@chimera>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera>
	 <_yaHeGjHEzG.A.FIH.7sGlKB@chimera>
Date: Wed, 26 Aug 2009 09:09:44 +0300
Message-ID: <84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com>
Subject: Re: [Bug #14016] mm/ipw2200 regression
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 11:34 PM, Rafael J. Wysocki<rjw@sisk.pl> wrote:
> This message has been generated automatically as a part of a report
> of recent regressions.
>
> The following bug entry is on the current list of known regressions
> from 2.6.30. =A0Please verify if it still should be listed and let me kno=
w
> (either way).
>
> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D1401=
6
> Subject =A0 =A0 =A0 =A0 : mm/ipw2200 regression
> Submitter =A0 =A0 =A0 : Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2009-08-15 16:56 (11 days old)
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1250364372=
21408&w=3D4

If am reading the page allocator dump correctly, there's plenty of
pages left but we're unable to satisfy an order 6 allocation. There's
no slab allocator involved so the page allocator changes that went
into 2.6.31 seem likely. Mel, ideas?

Bartlomiej, can we see your .config, please?

                                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
