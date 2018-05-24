Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BEDBB6B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 16:38:08 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t2-v6so970665pgo.0
        for <linux-mm@kvack.org>; Thu, 24 May 2018 13:38:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f69-v6si22247044plb.503.2018.05.24.13.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 13:38:07 -0700 (PDT)
Date: Thu, 24 May 2018 13:38:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
Message-Id: <20180524133805.6e9bfd4bf48de065ce1d7611@linux-foundation.org>
In-Reply-To: <6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
	<1525403506-6750-1-git-send-email-hejianet@gmail.com>
	<20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
	<2cd6b39b-1496-bbd5-9e31-5e3dcb31feda@arm.com>
	<6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki K Poulose <Suzuki.Poulose@arm.com>
Cc: Jia He <hejianet@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>

On Thu, 24 May 2018 09:44:16 +0100 Suzuki K Poulose <Suzuki.Poulose@arm.com=
> wrote:

> On 14/05/18 10:45, Suzuki K Poulose wrote:
> > On 10/05/18 00:31, Andrew Morton wrote:
> >> On Fri,=A0 4 May 2018 11:11:46 +0800 Jia He <hejianet@gmail.com> wrote:
> >>
> >>> In our armv8a server(QDF2400), I noticed lots of WARN_ON caused by PA=
GE_SIZE
> >>> unaligned for rmap_item->address under memory pressure tests(start 20=
 guests
> >>> and run memhog in the host).
> >>>
> >>> ...
> >>>
> >>> In rmap_walk_ksm, the rmap_item->address might still have the STABLE_=
FLAG,
> >>> then the start and end in handle_hva_to_gpa might not be PAGE_SIZE al=
igned.
> >>> Thus it will cause exceptions in handle_hva_to_gpa on arm64.
> >>>
> >>> This patch fixes it by ignoring(not removing) the low bits of address=
 when
> >>> doing rmap_walk_ksm.
> >>>
> >>> Signed-off-by: jia.he@hxt-semitech.com
> >>
> >> I assumed you wanted this patch to be committed as
> >> From:jia.he@hxt-semitech.com rather than From:hejianet@gmail.com, so I
> >> made that change.=A0 Please let me know if this was inappropriate.
> >>
> >> You can do this yourself by adding an explicit From: line to the very
> >> start of the patch's email text.
> >>
> >> Also, a storm of WARN_ONs is pretty poor behaviour.=A0 Is that the only
> >> misbehaviour which this bug causes?=A0 Do you think the fix should be
> >> backported into earlier kernels?
> >>
>=20
>=20
> Jia, Andrew,
>=20
> What is the status of this patch ?
>=20

I have it scheduled for 4.18-rc1, with a cc:stable for backporting.

I'd normally put such a fix into 4.17-rcX but I'd like to give Hugh
time to review it and to generally give it a bit more time for review
and test.

Have you tested it yourself?
