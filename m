Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1743C282CC
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85EA42081B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:09:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="H8P9hr+7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85EA42081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6478E0066; Mon,  4 Feb 2019 18:09:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 165148E001C; Mon,  4 Feb 2019 18:09:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 006648E0066; Mon,  4 Feb 2019 18:09:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF91A8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 18:09:14 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r16so914153pgr.15
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 15:09:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=0PF5MvnApFJQNRt7Z4nfADTAoB3bU8ybJC0/RUb3Drw=;
        b=bcv7rJbszX5gJWxtdtnnLXA3WSST8EFe/39EhFuA0qUCgnt7RFqQunQk7m0uRMHWPP
         H6JqsbhO5dB0LsgmReVd7IOLuu5Q5V9kgByW8nx0sYpUJPleHSQVLWaFJIfIXHp/kcks
         OIPwF5ZT7zrHM+IIhK/j9vzWBBGrE9MT1Sn5zJVV75O/lVcj/3axQKocjpMQdAa/aaVn
         hY3boY9WufGhiME/2u6gKG8iMAbUpNzCxM5d46wDpm7vuESgAF9SWESLX8ifjTvAZLXp
         1AF5z6xzxEtTnpn43ogfIfU1W3iicUu8HyLGIIsbbKXDkfBuFDWBZyWcYCdyCPa3fRDK
         VtsQ==
X-Gm-Message-State: AHQUAubdfnyocBb9TYEFSOSYWqEoHFuATXoMm7pUrnq5UpWHTQ4DAOEJ
	S4uEFyqIuxRqN/QheVhHClznQuofnQzvZocD2Huc0dpE/T2Qijic8M3ExMhlMLRCgY2TallQlwQ
	pZ0d8G4yFFji3D8JfUaFHaOExoSLlziB8UwBra7TrR5Mp5hnk/qHEL0NmBARqeZhZUw==
X-Received: by 2002:a17:902:6bc7:: with SMTP id m7mr1949400plt.106.1549321754369;
        Mon, 04 Feb 2019 15:09:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZMzFApxmTXzvVnULA7mMgFY5VXNN1MNDX5iGekbnNN3O01h+LsxSBhFvg8D/GnVCGxf4FF
X-Received: by 2002:a17:902:6bc7:: with SMTP id m7mr1949348plt.106.1549321753658;
        Mon, 04 Feb 2019 15:09:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549321753; cv=none;
        d=google.com; s=arc-20160816;
        b=SDBnJWZVkxcvXmz2N52LmZKu6cj4aIMCezfbugiSYSP20WsegDTSOO27Tkuum8kSjf
         09d4b0Pt8yApinXcfbu246k8Rm+0/d0dHMaXkTftVTEy/tpJXyQ0w9z3mKcVD6bXWcXJ
         AiF/vTYMl33LWzn440pIxhLJne3nio6edsoPdNHKvcHUfrdADMBK9EnIen2hGQao7KiZ
         9DvoqhCOKmVjHPnhtf0UGdRsH9E3Wtwy1XulaYeKFTax477sw4/Nh4WSQGCJYUtVmZEw
         BTmJI5aP9ASJEA52I7PVR8eg73/85l1DVr2OeUN9bG+gbdC6tgYtAyJ1YgEXaDu1UKQR
         ZCmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=0PF5MvnApFJQNRt7Z4nfADTAoB3bU8ybJC0/RUb3Drw=;
        b=S9mQoo3souqXuvIUTPgOyps6E1j1EYmts0ZtYk4GgEWynaaGc5aGmDtzRBWBpwLRka
         CyjTCZFuBplcGs2gc8hFsS3n81D/5DpQ1tPPJRDswHjT2RHEj6ShzMcyKVH7UdnGx7cW
         ovtS+ncPfHMWzkVfIqHvgt8iTOl/dSnKpeJ/BSLSyDbqJRjtBs4OzNFlC3Nz3JD/yYA1
         fIKUbnyJjMg68PmCV9LI2pXJVfmn5j6vBWiuOpZKNcKS7CVSLIdLJM5s/5nhUp1QK8VC
         KW/gKhtY8hqjf2dtNflT8YIhcnuzFUyiN056+ifw0Q7otm3tV+0rfiknLGzB8ryZJDXh
         Po/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=H8P9hr+7;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id x64si1348163pfb.120.2019.02.04.15.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 15:09:12 -0800 (PST)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=H8P9hr+7;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43tk122txKz9sN8;
	Tue,  5 Feb 2019 10:09:10 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1549321750;
	bh=5kmpAnNrz+J+6YGsz/aVer0CpkQVY3yk0di/ENxgr8k=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=H8P9hr+7S7OKYQXtT1H3GvO6gB9/DkhAuj3/THRfmJASTrmGsGlgcoEtosyGhwioO
	 INCcRhxIUESJXQThuo5LecF6Yo/O8qb+AzciP41EF0+4nJOC+RVUxsiNUM194/Orj4
	 HOoHcNbqCAnXiWMuOhLgUNJQruArTiXv11EZp5zfzcy0hr/nwwYSp7gzIY9FeSwkNl
	 PSJplMBrXA0/7M7H5kw/63bmi+d/Rh+7Cx/jJEzMzC0FBUiR+jnj98A3Xpvp6FDqPD
	 nAJX9kpMp436D6ndP1VUM4TWMqTS7VGFN6qGRCAF6aGTGhdZpID6P1r/nMQA6GAvi3
	 x8C6tkKIPlkjg==
Date: Tue, 5 Feb 2019 10:08:53 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org, Andrew Morton
 <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2 10/21] memblock: refactor internal allocation
 functions
Message-ID: <20190205100853.76425a4b@canb.auug.org.au>
In-Reply-To: <878sywndr6.fsf@concordia.ellerman.id.au>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
	<1548057848-15136-11-git-send-email-rppt@linux.ibm.com>
	<87ftt5nrcn.fsf@concordia.ellerman.id.au>
	<20190203113915.GC8620@rapoport-lnx>
	<878sywndr6.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/OzwveUY.oxkkzj/x37Y1z+B"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/OzwveUY.oxkkzj/x37Y1z+B
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 04 Feb 2019 19:45:17 +1100 Michael Ellerman <mpe@ellerman.id.au> wr=
ote:
>
> Mike Rapoport <rppt@linux.ibm.com> writes:
> > On Sun, Feb 03, 2019 at 08:39:20PM +1100, Michael Ellerman wrote: =20
> >> Mike Rapoport <rppt@linux.ibm.com> writes: =20
> >> > Currently, memblock has several internal functions with overlapping
> >> > functionality. They all call memblock_find_in_range_node() to find f=
ree
> >> > memory and then reserve the allocated range and mark it with kmemlea=
k.
> >> > However, there is difference in the allocation constraints and in fa=
llback
> >> > strategies. =20
> ...
> >>=20
> >> This is causing problems on some of my machines. =20
> ...
> >>=20
> >> On some of my other systems it does that, and then panics because it
> >> can't allocate anything at all:
> >>=20
> >> [    0.000000] numa:   NODE_DATA [mem 0x7ffcaee80-0x7ffcb3fff]
> >> [    0.000000] numa:   NODE_DATA [mem 0x7ffc99d00-0x7ffc9ee7f]
> >> [    0.000000] numa:     NODE_DATA(1) on node 0
> >> [    0.000000] Kernel panic - not syncing: Cannot allocate 20864 bytes=
 for node 16 data
> >> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc4-gccN-=
next-20190201-gdc4c899 #1
> >> [    0.000000] Call Trace:
> >> [    0.000000] [c0000000011cfca0] [c000000000c11044] dump_stack+0xe8/0=
x164 (unreliable)
> >> [    0.000000] [c0000000011cfcf0] [c0000000000fdd6c] panic+0x17c/0x3e0
> >> [    0.000000] [c0000000011cfd90] [c000000000f61bc8] initmem_init+0x12=
8/0x260
> >> [    0.000000] [c0000000011cfe60] [c000000000f57940] setup_arch+0x398/=
0x418
> >> [    0.000000] [c0000000011cfee0] [c000000000f50a94] start_kernel+0xa0=
/0x684
> >> [    0.000000] [c0000000011cff90] [c00000000000af70] start_here_common=
+0x1c/0x52c
> >> [    0.000000] Rebooting in 180 seconds..
> >>=20
> >>=20
> >> So there's something going wrong there, I haven't had time to dig into
> >> it though (Sunday night here). =20
> >
> > Yeah, I've misplaced 'nid' and 'MEMBLOCK_ALLOC_ACCESSIBLE' in
> > memblock_phys_alloc_try_nid() :(
> >
> > Can you please check if the below patch fixes the issue on your systems=
? =20
>=20
> Yes it does, thanks.
>=20
> Tested-by: Michael Ellerman <mpe@ellerman.id.au>
>=20
> cheers
>=20
>=20
> > From 5875b7440e985ce551e6da3cb28aa8e9af697e10 Mon Sep 17 00:00:00 2001
> > From: Mike Rapoport <rppt@linux.ibm.com>
> > Date: Sun, 3 Feb 2019 13:35:42 +0200
> > Subject: [PATCH] memblock: fix parameter order in
> >  memblock_phys_alloc_try_nid()
> >
> > The refactoring of internal memblock allocation functions used wrong or=
der
> > of parameters in memblock_alloc_range_nid() call from
> > memblock_phys_alloc_try_nid().
> > Fix it.
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  mm/memblock.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index e047933..0151a5b 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -1402,8 +1402,8 @@ phys_addr_t __init memblock_phys_alloc_range(phys=
_addr_t size,
> > =20
> >  phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_=
addr_t align, int nid)
> >  {
> > -	return memblock_alloc_range_nid(size, align, 0, nid,
> > -					MEMBLOCK_ALLOC_ACCESSIBLE);
> > +	return memblock_alloc_range_nid(size, align, 0,
> > +					MEMBLOCK_ALLOC_ACCESSIBLE, nid);
> >  }
> > =20
> >  /**
> > --=20
> > 2.7.4

I have applied that patch to the akpm tree in linux-next from today.

--=20
Cheers,
Stephen Rothwell

--Sig_/OzwveUY.oxkkzj/x37Y1z+B
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlxYxgUACgkQAVBC80lX
0GxEuAf9GsugDDdRCLDmTMD00eIytyOVIEpA9SyPp6+OfJFr6LAe4od3NRsvyLHo
qt5zEPzj9VXyImq9gQF3NxuITf21Jo4a260SueoJ9/tMLpcxvqb/e8/S5isnJV/j
IPRYpZoynZW1VIv03G04Q5NZe9MtAECrYd0pqva8SbxDBMnbisbU0iht4kpZGWAg
6uroMUsJmIzIYM6K5AHwqxi4cSHtZA+ft/qTbbTxExIs1e9LmmDzSEZ9SlSO0xD+
NL9+pT3mDDP+YqHhEWq/cnBmYm1IMoLpXDnevH9TRhaLsdlBm07Tu2j1zcMn1Bb6
l7AHZto9y6UlB9AjC/KE+LHFK61c+g==
=lBAx
-----END PGP SIGNATURE-----

--Sig_/OzwveUY.oxkkzj/x37Y1z+B--

