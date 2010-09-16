Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3157B6B008A
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:51:01 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o8GGorO4010766
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:50:55 -0700
Received: from gyb11 (gyb11.prod.google.com [10.243.49.75])
	by kpbe13.cbf.corp.google.com with ESMTP id o8GGooYZ012556
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:50:51 -0700
Received: by gyb11 with SMTP id 11so7177gyb.22
        for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:50:41 -0700 (PDT)
Date: Thu, 16 Sep 2010 09:50:24 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] Document the new Anonymous field in smaps.
In-Reply-To: <201009161135.00129.knikanth@suse.de>
Message-ID: <alpine.DEB.2.00.1009160940330.24798@tigran.mtv.corp.google.com>
References: <AANLkTini3k1hK-9RM6io0mOf4VoDzGpbUEpiv=WHfhEW@mail.gmail.com> <201009160856.25923.knikanth@suse.de> <20100916125147.CA08.A69D9226@jp.fujitsu.com> <201009161135.00129.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="380388936-1970376381-1284655827=:24798"
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Richard Guenther <rguenther@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--380388936-1970376381-1284655827=:24798
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 16 Sep 2010, Nikanth Karthikesan wrote:

> Sorry, I missed to add documentation, when I sent the patch. This depends=
 on
> the patch titled, "[PATCH] Export amount of anonymous memory in a mapping=
 via
> smaps".
>=20
> Thanks
> Nikanth
>=20
>=20
> Document the new Anonymous field in smaps.
>=20
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

Thanks for adding this, but...

>=20
> ---
>=20
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesyste=
ms/proc.txt
> index a6aca87..75c7368 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -370,6 +370,7 @@ Shared_Dirty:          0 kB
>  Private_Clean:         0 kB
>  Private_Dirty:         0 kB
>  Referenced:          892 kB
> +Anonymous:             0 kB
>  Swap:                  0 kB
>  KernelPageSize:        4 kB
>  MMUPageSize:           4 kB
> @@ -380,7 +381,10 @@ the amount of the mapping that is currently resident=
 in RAM, the "proportional
>  set size=E2=80=9D (divide each shared page by the number of processes sh=
aring it), the
>  number of clean and dirty shared pages in the mapping, and the number of=
 clean
>  and dirty private pages in the mapping.  The "Referenced" indicates the =
amount
> -of memory currently marked as referenced or accessed.
> +of memory currently marked as referenced or accessed. The "Anonymous" sh=
ows
> +the amount of mapping that is not associated with a file. Even the priva=
te
> +pages in a mapping associated with a file, would become anonymous, when =
they
> +are modified.

=2E.. unfortunately it needs rewording, because you're describing it well
with respect to MAP_SHARED versus MAP_PRIVATE, but /proc/pid/smaps has a
different definition of whether pages are shared or private, just depending
on their mapcount at the instant.

Indeed, adding a comment on that would be helpful too, if you've time.

> =20
>  This file is only present if the CONFIG_MMU kernel configuration option =
is
>  enabled.
--380388936-1970376381-1284655827=:24798--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
