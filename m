Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F354DC31E51
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:44:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A591120B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:44:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W+j0kD9y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A591120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E2056B0006; Tue, 18 Jun 2019 23:44:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 493278E0002; Tue, 18 Jun 2019 23:44:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35AC98E0001; Tue, 18 Jun 2019 23:44:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3A286B0006
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:44:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a20so8040211pfn.19
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 20:44:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=EGHEaYjfXjUJTdauQ4fG3Qy+hvFG8OA2oIP4ZHxwa88=;
        b=HWcx9vn3ISPuxioJ/Fa0hwDjygCeZlnr2TYJHkr2RvODXg5t//npEcrtIaavB0aRDA
         2n9OME/Q+lPMF71Q8DeqAc284KyCdibZyB1fXA6/ICVuxoj45tx9sJ7P/VSkSmjF9AhU
         XrAaGKIfW8AB4DaRtgRCLc+Ur70hGTw5+ova3+DMrP9gmYacEf25IHPfMvvJBORImYaR
         uVyvRBs45QrugnJJFQ83dKeavsabeSbU+3X4xK4lfENpvnultMh9YCrcNQR3jQbLbdUF
         o+Ot/iVAswUTyYIYUI3utBfpBPsBpFT5CVI+HN1qM6L57xaJtsVufpx2HXlZtg/hX8WI
         t3Aw==
X-Gm-Message-State: APjAAAXQY4NhDvZ44tvnok3J4eKyNe7n3ZTeK2+oUrrrzZbxlCNqVRWH
	PhZITSv419H2VIdNA8WL6kElAENOSw54Adtq7gSbf33UsHOYi227zqRu6MqalAq2ulRUrHzG+hS
	ddtaIp/21hkj2uXNFdpFngH8kt/vtU/oWDbp/+3g4zyRv/a8s/bGUtl4YpjHaaIA2Pw==
X-Received: by 2002:a63:4406:: with SMTP id r6mr5770089pga.250.1560915865496;
        Tue, 18 Jun 2019 20:44:25 -0700 (PDT)
X-Received: by 2002:a63:4406:: with SMTP id r6mr5770058pga.250.1560915864792;
        Tue, 18 Jun 2019 20:44:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560915864; cv=none;
        d=google.com; s=arc-20160816;
        b=fD3bYhSlp3+xjDCrNFuoKGEajEBCq+57E4qlKpBAWZ4Ql2Sv9OZK7hlVCYfAftYOun
         WzeWAx6ZlINHicEIPBv6/STr0JeyD+Im64TLEXcDyuyU3wZRyea9Th3QbT4aPKmG2F56
         IX94Lwvmjx5uVmOo0hbPHyhtS32KUjTUduVqe/BfhO//SAVh6ivTZneuyb6khX0v2zw9
         uUEP6Q44Liv61xbJraHnTQMManCxRzlaZSvbc5u7DKva9NBWy83xpyErZYQ8ammsfCuW
         8OK0YxoN78h/iVIrNW9ZwpEg0JB3L8J66ETagPbx0Lvvh3Vm8huBuY0dCUFbFsz6fxtC
         U6zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=EGHEaYjfXjUJTdauQ4fG3Qy+hvFG8OA2oIP4ZHxwa88=;
        b=zBbEGcfSCSXwPpjhDVXNkHZif5AraNJlqIy7xW+FKjhLBE7K9RGZFIwDnNTOADWXso
         Z/ukplIuk66BXRtNoIdADtXw4NwNMRkE1zEKmmYjbKTQVfOuMcPJ6jJ2QArr6oi1AXX5
         O0gg+ZQcuVnB3pr/gWDRp9zjvgLuns+Y1FD6HYuNBhQqD2K2DQAuwtR2EoHYmGWBEIrM
         TB6Nj5sOCmyY2I2JTZ/Taw7kuAbZ/yo42d8Ghl8QUTp7a+9Ua5NAx0QhkRSDLG6r7fzb
         UcPSNmHxEwzbtmm7I7sjHUmtPpxgfs2QnTs/OCi57BMioQLRhFxgcGNU+l4uu37nU2x9
         SHug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=W+j0kD9y;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x21sor16691576pfm.53.2019.06.18.20.44.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 20:44:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=W+j0kD9y;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=EGHEaYjfXjUJTdauQ4fG3Qy+hvFG8OA2oIP4ZHxwa88=;
        b=W+j0kD9yojaW+hMlyk96Hha2xluF+17N7BX9ERK2TgvEPC51BC4u2dq+nw03r1DWnx
         qvEJnZfOncY8GNkfHLYyFd1gUqK/DmwkvbMMbTo2XYoe4knHRkooq2LDS7hxglixe+lt
         HsY3uvWPW/XZKJ44ul+TFBuD0gLNwY9RuVBPX1VgqzRWsFUjTBvVUaOh+u4eFiw+CObP
         Jp83FXUzxjExnl4Uyx+Nr2FrIZkfzQjY4+aPzkAcfTPALITve38+sCyAndT+LyNUeJU7
         T/GcE419O6pmuHckNP5CbqtcPwnuADo1M5bulo/e0geUj9rCOlWLnno8sobB9iPLWqlm
         gz1A==
X-Google-Smtp-Source: APXvYqwB7lHrI569djdy3eQ/PTdJiIHmfUvLO5bVVwFEwAzySywuMBRsshv/4G+mG7op0lLRUOHdYQ==
X-Received: by 2002:a62:68c4:: with SMTP id d187mr126870371pfc.245.1560915864395;
        Tue, 18 Jun 2019 20:44:24 -0700 (PDT)
Received: from localhost (193-116-92-108.tpgi.com.au. [193.116.92.108])
        by smtp.gmail.com with ESMTPSA id r1sm11612280pfq.100.2019.06.18.20.44.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 20:44:23 -0700 (PDT)
Date: Wed, 19 Jun 2019 13:39:19 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org,
	Russell Currey <ruscur@russell.cc>
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<20190610043838.27916-4-npiggin@gmail.com>
	<b79bf11d-43c7-88c9-8395-239625a1bdcf@c-s.fr>
In-Reply-To: <b79bf11d-43c7-88c9-8395-239625a1bdcf@c-s.fr>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560915223.if2qg1yc7k.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christophe Leroy's on June 11, 2019 3:39 pm:
>=20
>=20
> Le 10/06/2019 =C3=A0 06:38, Nicholas Piggin a =C3=A9crit=C2=A0:
>> For platforms that define HAVE_ARCH_HUGE_VMAP, have vmap allow vmalloc t=
o
>> allocate huge pages and map them
>=20
> Will this be compatible with Russell's series=20
> https://patchwork.ozlabs.org/patch/1099857/ for the implementation of=20
> STRICT_MODULE_RWX ?
> I see that apply_to_page_range() have things like BUG_ON(pud_huge(*pud));
>=20
> Might also be an issue for arm64 as I think Russell's implementation=20
> comes from there.

Yeah you're right (and correct about arm64 problem). I'll fix that up.

>> +static int vmap_hpages_range(unsigned long start, unsigned long end,
>> +			   pgprot_t prot, struct page **pages,
>> +			   unsigned int page_shift)
>> +{
>> +	BUG_ON(page_shift !=3D PAGE_SIZE);
>=20
> Do we really need a BUG_ON() there ? What happens if this condition is=20
> true ?

If it's true then vmap_pages_range would die horribly reading off the
end of the pages array thinking they are struct page pointers.

I guess it could return failure.

>> +	return vmap_pages_range(start, end, prot, pages);
>> +}
>> +#endif
>> +
>> +
>>   int is_vmalloc_or_module_addr(const void *x)
>>   {
>>   	/*
>> @@ -462,7 +498,7 @@ struct page *vmalloc_to_page(const void *vmalloc_add=
r)
>>   {
>>   	unsigned long addr =3D (unsigned long) vmalloc_addr;
>>   	struct page *page =3D NULL;
>> -	pgd_t *pgd =3D pgd_offset_k(addr);
>> +	pgd_t *pgd;
>>   	p4d_t *p4d;
>>   	pud_t *pud;
>>   	pmd_t *pmd;
>> @@ -474,27 +510,38 @@ struct page *vmalloc_to_page(const void *vmalloc_a=
ddr)
>>   	 */
>>   	VIRTUAL_BUG_ON(!is_vmalloc_or_module_addr(vmalloc_addr));
>>  =20
>> +	pgd =3D pgd_offset_k(addr);
>>   	if (pgd_none(*pgd))
>>   		return NULL;
>> +
>>   	p4d =3D p4d_offset(pgd, addr);
>>   	if (p4d_none(*p4d))
>>   		return NULL;
>> -	pud =3D pud_offset(p4d, addr);
>> +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
>=20
> Do we really need that ifdef ? Won't p4d_large() always return 0 when is=20
> not set ?
> Otherwise, could we use IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP) instead ?
>=20
> Same several places below.

Possibly some of them are not defined without HAVE_ARCH_HUGE_VMAP
I think. I'll try to apply this pattern as much as possible.

>> @@ -2541,14 +2590,17 @@ static void *__vmalloc_area_node(struct vm_struc=
t *area, gfp_t gfp_mask,
>>   				 pgprot_t prot, int node)
>>   {
>>   	struct page **pages;
>> +	unsigned long addr =3D (unsigned long)area->addr;
>> +	unsigned long size =3D get_vm_area_size(area);
>> +	unsigned int page_shift =3D area->page_shift;
>> +	unsigned int shift =3D page_shift + PAGE_SHIFT;
>>   	unsigned int nr_pages, array_size, i;
>>   	const gfp_t nested_gfp =3D (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO=
;
>>   	const gfp_t alloc_mask =3D gfp_mask | __GFP_NOWARN;
>>   	const gfp_t highmem_mask =3D (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
>> -					0 :
>> -					__GFP_HIGHMEM;
>> +					0 : __GFP_HIGHMEM;
>=20
> This patch is already quite big, shouldn't this kind of unrelated=20
> cleanups be in another patch ?

Okay, 2 against 1. I'll minimise changes like this.

Thanks,
Nick

=

