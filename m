Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 484EC6B3FD9
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:11:20 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t199so15655620wmd.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:11:20 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10052.outbound.protection.outlook.com. [40.107.1.52])
        by mx.google.com with ESMTPS id b9si105531wro.92.2018.11.26.04.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Nov 2018 04:11:18 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 1/5] mm: mmap: Allow for "high" userspace addresses
Date: Mon, 26 Nov 2018 12:11:16 +0000
Message-ID: <20181126121100.GA2012@capper-debian.cambridge.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-2-steve.capper@arm.com>
 <20181123181744.GK3360@arrakis.emea.arm.com>
In-Reply-To: <20181123181744.GK3360@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F1B34D54C4838C49A4FC9FD0E5E8671B@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Fri, Nov 23, 2018 at 06:17:44PM +0000, Catalin Marinas wrote:
> On Wed, Nov 14, 2018 at 01:39:16PM +0000, Steve Capper wrote:
> > This patch adds support for "high" userspace addresses that are
> > optionally supported on the system and have to be requested via a hint
> > mechanism ("high" addr parameter to mmap).
> >=20
> > Architectures such as powerpc and x86 achieve this by making changes to
> > their architectural versions of arch_get_unmapped_* functions. However,
> > on arm64 we use the generic versions of these functions.
> >=20
> > Rather than duplicate the generic arch_get_unmapped_* implementations
> > for arm64, this patch instead introduces two architectural helper macro=
s
> > and applies them to arch_get_unmapped_*:
> >  arch_get_mmap_end(addr) - get mmap upper limit depending on addr hint
> >  arch_get_mmap_base(addr, base) - get mmap_base depending on addr hint
> >=20
> > If these macros are not defined in architectural code then they default
> > to (TASK_SIZE) and (base) so should not introduce any behavioural
> > changes to architectures that do not define them.
> >=20
> > Signed-off-by: Steve Capper <steve.capper@arm.com>
>=20
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks!
