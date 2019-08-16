Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FAF9C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:04:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C52D32077C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:04:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="FEQpuqzB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C52D32077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B7E86B0005; Fri, 16 Aug 2019 04:04:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 368746B0006; Fri, 16 Aug 2019 04:04:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 256AA6B0007; Fri, 16 Aug 2019 04:04:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0173.hostedemail.com [216.40.44.173])
	by kanga.kvack.org (Postfix) with ESMTP id EFF266B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 04:04:37 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A00508248AB8
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:04:37 +0000 (UTC)
X-FDA: 75827554194.15.sheet08_6287f46193b5e
X-HE-Tag: sheet08_6287f46193b5e
X-Filterd-Recvd-Size: 6828
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:04:36 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 468wpB2JnLz9tyXh;
	Fri, 16 Aug 2019 10:04:34 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=FEQpuqzB; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id lA6E5j-wl7KL; Fri, 16 Aug 2019 10:04:34 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 468wpB18g7z9tyXf;
	Fri, 16 Aug 2019 10:04:34 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1565942674; bh=IwjKUZFfoo6+PRRG4jenIhfB1rMdpLyzjhvMP8dxpr0=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=FEQpuqzBrSVbeKFBFK3dRok8Kmm2wsRcRJPMtfdKsxfbahPS7sr6PMMsWl2suPWGA
	 Yu2x+G04O+sjac27nfrX3XV2zznq3SWOQr22f4N3r8WqLh3hr80tXr3bVPGcJG6UMI
	 Gd9xxHOvnsFzfvNbpwctNnmfrjDPHOg4ZztFnpgw=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 4F3288B776;
	Fri, 16 Aug 2019 10:04:35 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id lzTZTjOCDTZS; Fri, 16 Aug 2019 10:04:35 +0200 (CEST)
Received: from [172.25.230.101] (po15451.idsi0.si.c-s.fr [172.25.230.101])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D22958B754;
	Fri, 16 Aug 2019 10:04:34 +0200 (CEST)
Subject: Re: [PATCH v4 3/3] x86/kasan: support KASAN_VMALLOC
To: Daniel Axtens <dja@axtens.net>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, x86@kernel.org, aryabinin@virtuozzo.com,
 glider@google.com, luto@kernel.org, linux-kernel@vger.kernel.org,
 mark.rutland@arm.com, dvyukov@google.com
Cc: linuxppc-dev@lists.ozlabs.org, gor@linux.ibm.com
References: <20190815001636.12235-1-dja@axtens.net>
 <20190815001636.12235-4-dja@axtens.net>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <d8d2d0ae-8ebc-d572-7a62-f17f28cb1bac@c-s.fr>
Date: Fri, 16 Aug 2019 10:04:27 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190815001636.12235-4-dja@axtens.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 15/08/2019 =C3=A0 02:16, Daniel Axtens a =C3=A9crit=C2=A0:
> In the case where KASAN directly allocates memory to back vmalloc
> space, don't map the early shadow page over it.

If early shadow page is not mapped, any bad memory access will Oops on=20
the shadow access instead of Oopsing on the real bad access.

You should still map early shadow page, and replace it with real page=20
when needed.

Christophe

>=20
> We prepopulate pgds/p4ds for the range that would otherwise be empty.
> This is required to get it synced to hardware on boot, allowing the
> lower levels of the page tables to be filled dynamically.
>=20
> Acked-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Daniel Axtens <dja@axtens.net>
>=20
> ---
>=20
> v2: move from faulting in shadow pgds to prepopulating
> ---
>   arch/x86/Kconfig            |  1 +
>   arch/x86/mm/kasan_init_64.c | 61 ++++++++++++++++++++++++++++++++++++=
+
>   2 files changed, 62 insertions(+)
>=20
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 222855cc0158..40562cc3771f 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -134,6 +134,7 @@ config X86
>   	select HAVE_ARCH_JUMP_LABEL
>   	select HAVE_ARCH_JUMP_LABEL_RELATIVE
>   	select HAVE_ARCH_KASAN			if X86_64
> +	select HAVE_ARCH_KASAN_VMALLOC		if X86_64
>   	select HAVE_ARCH_KGDB
>   	select HAVE_ARCH_MMAP_RND_BITS		if MMU
>   	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> index 296da58f3013..2f57c4ddff61 100644
> --- a/arch/x86/mm/kasan_init_64.c
> +++ b/arch/x86/mm/kasan_init_64.c
> @@ -245,6 +245,52 @@ static void __init kasan_map_early_shadow(pgd_t *p=
gd)
>   	} while (pgd++, addr =3D next, addr !=3D end);
>   }
>  =20
> +static void __init kasan_shallow_populate_p4ds(pgd_t *pgd,
> +		unsigned long addr,
> +		unsigned long end,
> +		int nid)
> +{
> +	p4d_t *p4d;
> +	unsigned long next;
> +	void *p;
> +
> +	p4d =3D p4d_offset(pgd, addr);
> +	do {
> +		next =3D p4d_addr_end(addr, end);
> +
> +		if (p4d_none(*p4d)) {
> +			p =3D early_alloc(PAGE_SIZE, nid, true);
> +			p4d_populate(&init_mm, p4d, p);
> +		}
> +	} while (p4d++, addr =3D next, addr !=3D end);
> +}
> +
> +static void __init kasan_shallow_populate_pgds(void *start, void *end)
> +{
> +	unsigned long addr, next;
> +	pgd_t *pgd;
> +	void *p;
> +	int nid =3D early_pfn_to_nid((unsigned long)start);
> +
> +	addr =3D (unsigned long)start;
> +	pgd =3D pgd_offset_k(addr);
> +	do {
> +		next =3D pgd_addr_end(addr, (unsigned long)end);
> +
> +		if (pgd_none(*pgd)) {
> +			p =3D early_alloc(PAGE_SIZE, nid, true);
> +			pgd_populate(&init_mm, pgd, p);
> +		}
> +
> +		/*
> +		 * we need to populate p4ds to be synced when running in
> +		 * four level mode - see sync_global_pgds_l4()
> +		 */
> +		kasan_shallow_populate_p4ds(pgd, addr, next, nid);
> +	} while (pgd++, addr =3D next, addr !=3D (unsigned long)end);
> +}
> +
> +
>   #ifdef CONFIG_KASAN_INLINE
>   static int kasan_die_handler(struct notifier_block *self,
>   			     unsigned long val,
> @@ -352,9 +398,24 @@ void __init kasan_init(void)
>   	shadow_cpu_entry_end =3D (void *)round_up(
>   			(unsigned long)shadow_cpu_entry_end, PAGE_SIZE);
>  =20
> +	/*
> +	 * If we're in full vmalloc mode, don't back vmalloc space with early
> +	 * shadow pages. Instead, prepopulate pgds/p4ds so they are synced to
> +	 * the global table and we can populate the lower levels on demand.
> +	 */
> +#ifdef CONFIG_KASAN_VMALLOC
> +	kasan_shallow_populate_pgds(
> +		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
> +		kasan_mem_to_shadow((void *)VMALLOC_END));
> +
> +	kasan_populate_early_shadow(
> +		kasan_mem_to_shadow((void *)VMALLOC_END + 1),
> +		shadow_cpu_entry_begin);
> +#else
>   	kasan_populate_early_shadow(
>   		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
>   		shadow_cpu_entry_begin);
> +#endif
>  =20
>   	kasan_populate_shadow((unsigned long)shadow_cpu_entry_begin,
>   			      (unsigned long)shadow_cpu_entry_end, 0);
>=20

