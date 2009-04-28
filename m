Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 315CF6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 03:11:29 -0400 (EDT)
Received: by ewy8 with SMTP id 8so422621ewy.38
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 00:11:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090428014920.217785938@intel.com>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.217785938@intel.com>
Date: Tue, 28 Apr 2009 10:11:37 +0300
Message-ID: <93e6a6040904280011o25c68e9o672cf2ab64af26cd@mail.gmail.com>
Subject: Re: [PATCH 1/5] pagemap: document clarifications
From: Tommi Rantala <tt.rantala@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

2009/4/28 Wu Fengguang <fengguang.wu@intel.com>:
> Some bit ranges were inclusive and some not.
> Fix them to be consistently inclusive.
>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =A0Documentation/vm/pagemap.txt | =A0 =A06 +++---
> =A01 file changed, 3 insertions(+), 3 deletions(-)
>
> --- mm.orig/Documentation/vm/pagemap.txt
> +++ mm/Documentation/vm/pagemap.txt
> @@ -12,9 +12,9 @@ There are three components to pagemap:
> =A0 =A0value for each virtual page, containing the following data (from
> =A0 =A0fs/proc/task_mmu.c, above pagemap_read):
>
> - =A0 =A0* Bits 0-55 =A0page frame number (PFN) if present
> + =A0 =A0* Bits 0-54 =A0page frame number (PFN) if present
> =A0 =A0 * Bits 0-4 =A0 swap type if swapped
> - =A0 =A0* Bits 5-55 =A0swap offset if swapped
> + =A0 =A0* Bits 5-54 =A0swap offset if swapped
> =A0 =A0 * Bits 55-60 page shift (page size =3D 1<<page shift)
> =A0 =A0 * Bit =A061 =A0 =A0reserved for future use
> =A0 =A0 * Bit =A062 =A0 =A0page swapped

The same fix should be applied to fs/proc/task_mmu.c as well,
it includes the same description of the bits.

Regards,
Tommi Rantala

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
