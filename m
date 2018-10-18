Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 641EB6B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:35:43 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 36so3214956oth.6
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 03:35:43 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20046.outbound.protection.outlook.com. [40.107.2.46])
        by mx.google.com with ESMTPS id 6-v6si8918734oid.223.2018.10.18.03.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 03:35:42 -0700 (PDT)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V2 1/4] mm: mmap: Allow for "high" userspace addresses
Date: Thu, 18 Oct 2018 10:35:38 +0000
Message-ID: <20181018103528.us35ibcpbcducuyr@capper-debian.cambridge.arm.com>
References: <20181017163459.20175-1-steve.capper@arm.com>
 <20181017163459.20175-2-steve.capper@arm.com>
 <20181017164815.GA7966@bombadil.infradead.org>
In-Reply-To: <20181017164815.GA7966@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <63BCB2A2CE613D4298524A72F6E9E6D2@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "jcm@redhat.com" <jcm@redhat.com>, nd <nd@arm.com>

On Wed, Oct 17, 2018 at 09:48:15AM -0700, Matthew Wilcox wrote:
> On Wed, Oct 17, 2018 at 05:34:56PM +0100, Steve Capper wrote:
> > This patch adds support for "high" userspace addresses that are
> > optionally supported on the system and have to be requested via a hint
> > mechanism ("high" addr parameter to mmap).
> >=20
> > Rather than duplicate the arch_get_unmapped_* stock implementations,
> > this patch instead introduces two architectural helper macros and
> > applies them to arch_get_unmapped_*:
> >  arch_get_mmap_end(addr) - get mmap upper limit depending on addr hint
> >  arch_get_mmap_base(addr, base) - get mmap_base depending on addr hint
> >=20
> > If these macros are not defined in architectural code then they default
> > to (TASK_SIZE) and (base) so should not introduce any behavioural
> > changes to architectures that do not define them.
>=20
> Can you explain (in the changelog) why we need to do this for arm64
> when it wasn't needed for the equivalent feature on x86-64?  I think the
> answer is that x86-64 already has its own arch_get_unmapped* functions an=
d
> rather than duplicating arch_get_unmapped* for arm64, you want to continu=
e
> using the generic ones with just this minor hooking.  But I'd like that
> spelled out explicitly for the next person who comes along and wonders.
>

Thanks Matthew,
Yes we thought it better to make an unobtrusive change to the generic
code rather than copy it over to arm64 (whilst x86 already had an
architecture specific version that was patched).

I will make the commit log a lot clearer.

Cheers,
--=20
Steve
