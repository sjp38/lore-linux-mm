Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id A0EB56B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 14:30:03 -0400 (EDT)
From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please revert 53a59fc67!
References: <52050382.9060802@gmail.com> <520BB225.8030807@gmail.com>
	<20130814174039.GA24033@dhcp22.suse.cz>
	<CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com>
	<20130814182756.GD24033@dhcp22.suse.cz>
	<CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com>
	<520C9E78.2020401@gmail.com>
	<CA+55aFy2D2hTc_ina1DvungsCL4WU2OTM=bnVb8sDyDcGVCBEQ@mail.gmail.com>
	<CA+55aFxuUrcod=X2t2yqR_zJ4s1uaCsGB-p1oLTQrG+y+Z2PbA@mail.gmail.com>
Date: Thu, 15 Aug 2013 20:29:11 +0200
In-Reply-To: <CA+55aFxuUrcod=X2t2yqR_zJ4s1uaCsGB-p1oLTQrG+y+Z2PbA@mail.gmail.com>
	(Linus Torvalds's message of "Thu, 15 Aug 2013 11:00:03 -0700")
Message-ID: <87ioz67qq0.fsf@nemi.mork.no>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ben Tebulin <tebulin@googlemail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> Comments? Especially s390, ARM, ia64, sh and um that I edited blindly...

I can see that :-)  You have a couple of "unsigned logn"s here.


Bj=C3=B8rn

> --- a/arch/arm64/include/asm/tlb.h
> +++ b/arch/arm64/include/asm/tlb.h
> @@ -35,6 +35,7 @@ struct mmu_gather {
>  	struct mm_struct	*mm;
>  	unsigned int		fullmm;
>  	struct vm_area_struct	*vma;
> +	unsigned long		start, end;
>  	unsigned long		range_start;
>  	unsigned long		range_end;
>  	unsigned int		nr;
> @@ -97,10 +98,12 @@ static inline void tlb_flush_mmu(struct mmu_gather *t=
lb)
>  }
>=20=20
>  static inline void
> -tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned in=
t fullmm)
> +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned lo=
ng start, unsigned logn end)

[..]

> diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
> index e61d43d9f689..47745b255721 100644
> --- a/arch/sh/include/asm/tlb.h
> +++ b/arch/sh/include/asm/tlb.h
> @@ -36,10 +36,12 @@ static inline void init_tlb_gather(struct mmu_gather =
*tlb)
>  }
>=20=20
>  static inline void
> -tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned in=
t full_mm_flush)
> +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned lo=
ng start, unsigned logn end)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
