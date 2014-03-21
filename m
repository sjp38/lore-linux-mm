Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9456B0287
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 19:37:08 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u57so2023295wes.36
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 16:37:07 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id xm2si2966332wib.82.2014.03.21.16.37.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 16:37:07 -0700 (PDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so949289wib.2
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 16:37:06 -0700 (PDT)
Subject: Re: [PATCH v2 1/3] kmemleak: allow freeing internal objects after kmemleak was disabled
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=GB2312
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <5326750E.1000004@huawei.com>
Date: Fri, 21 Mar 2014 23:37:03 +0000
Content-Transfer-Encoding: quoted-printable
Message-Id: <F7314A69-24BE-42B9-8E99-8F9292B397C4@arm.com>
References: <5326750E.1000004@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Li,

On 17 Mar 2014, at 04:07, Li Zefan <lizefan@huawei.com> wrote:
> Currently if kmemleak is disabled, the kmemleak objects can never be =
freed,
> no matter if it's disabled by a user or due to fatal errors.
>=20
> Those objects can be a big waste of memory.
>=20
>  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> 1200264 1197433  99%    0.30K  46164       26    369312K =
kmemleak_object
>=20
> With this patch, internal objects will be freed immediately if =
kmemleak is
> disabled explicitly by a user. If it's disabled due to a kmemleak =
error,
> The user will be informed, and then he/she can reclaim memory with:
>=20
> 	# echo off > /sys/kernel/debug/kmemleak
>=20
> v2: use "off" handler instead of "clear" handler to do this, suggested
>    by Catalin.

I think there was a slight misunderstanding. My point was about "echo
scan=3Doff=A1=B1 before =A1=B0echo off=A1=B1, they can just be squashed =
into the
same action of the latter.

I would keep the =A1=B0clear=A1=B1 part separately as per your first =
patch. I
recall people asked in the past to still be able to analyse the reports
even though kmemleak failed or was disabled.

Thanks,

Catalin=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
