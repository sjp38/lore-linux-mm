Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A043C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1F1B205F4
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:52:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="UElDFonO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1F1B205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F25F6B000A; Tue, 13 Aug 2019 10:52:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A48E6B000C; Tue, 13 Aug 2019 10:52:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3926B6B000D; Tue, 13 Aug 2019 10:52:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0218.hostedemail.com [216.40.44.218])
	by kanga.kvack.org (Postfix) with ESMTP id 17BEA6B000A
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:52:29 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C1DEF53B3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:52:28 +0000 (UTC)
X-FDA: 75817695576.27.alarm36_89fd315bc3c0a
X-HE-Tag: alarm36_89fd315bc3c0a
X-Filterd-Recvd-Size: 9426
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:52:28 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id e8so6076243qtp.7
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:52:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=L1TAnq5W0MO+agYpj3HyQqM1bwmIJh85mwQw/vdFBR0=;
        b=UElDFonO/n3cviTHkPS5S/srPOvtoI5soxS0RznRmW1r7Ajsw39Nkqr7oPdSqneCcN
         Q5NKhnJCE5xRBRGHuLrxwS8Z2p4aGHmoQVFA8HrjQKApwv5yh7/9zgVkltsUfJ6Hv1xo
         tJT1rrMn6UBf0bhzJJmuQR/LftMzqXc0huUL44yQAdUQ/hnCzDfv3GCykTmvRqdTE+03
         5yrW7uvzq71CiQ0H9XbNEPwXOBk6DXRZaC9MKoN4wCqfjquzPymOQg3g2kt7554wJTNh
         vlesvli4e1gl9KFxa2sa6/IDwDkuGPXB0rzOOkR+Eht1AzefnemOwViKAJSFK5Tdg5Op
         RWvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=L1TAnq5W0MO+agYpj3HyQqM1bwmIJh85mwQw/vdFBR0=;
        b=aKxiArsJ3HnsuCb4iWdiWyMabHZa1GYCVkM+MKd097Gd7zm4yL8F/lYw5QueUxB9rp
         dqOLn9xzkD8J8vrxhH+exEDUxPHiyOLwse/8Fa6SOIyq0NFFJuls5QkLR8xSnDBmFUcm
         9E8SA6F+10Hs19bSNxvdoH4+uwWfeRMrF0e8ey0cU8BBYNq9HzJlm4Ih+JInxAhezef6
         eebD+duaxvyWO+PK6gNWuk8yDW2jElNcOYusqgr6ztuHZ8xQSP+2KWbnbwn6MH1WPb/V
         MTxW3eb6D6jO8aD/gUQKiqXhD2ZCprLhjYD+3MMJUx0PBbSkpmFHcrWrv6nSJ1JtftGu
         VsxQ==
X-Gm-Message-State: APjAAAV/q1UvMGeISLuvCzBZUblX3mCg5We6dqaHuAtxbasF97zoaFZq
	E5+ExQDCxOZLrB2N0k1bNzGhHA==
X-Google-Smtp-Source: APXvYqxc0CKAJKFL7ppZt2JQ6EoGVK/4QoWoalO5KDGcmPiJn4jack/9101YxdQzfwnYf4XuynhW+w==
X-Received: by 2002:ac8:243d:: with SMTP id c58mr4809363qtc.388.1565707947422;
        Tue, 13 Aug 2019 07:52:27 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id u23sm7401613qkj.98.2019.08.13.07.52.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 07:52:26 -0700 (PDT)
Message-ID: <1565707945.8572.10.camel@lca.pw>
Subject: Re: [rgushchin:fix_vmstats 21/221]
 include/asm-generic/5level-fixup.h:14:18: error: unknown type name 'pgd_t';
 did you mean 'pid_t'?
From: Qian Cai <cai@lca.pw>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>, Johannes Weiner
	 <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux
	Memory Management List
	 <linux-mm@kvack.org>
Date: Tue, 13 Aug 2019 10:52:25 -0400
In-Reply-To: <201908131117.SThHOrZO%lkp@intel.com>
References: <201908131117.SThHOrZO%lkp@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-08-13 at 11:33 +0800, kbuild test robot wrote:
> tree:=C2=A0=C2=A0=C2=A0https://github.com/rgushchin/linux.git fix_vmsta=
ts
> head:=C2=A0=C2=A0=C2=A04ec858b5201ae067607e82706b36588631c1b990
> commit: 938dda772d9d05074bfe1baa0dc18873fbf4fedb [21/221] include/asm-
> generic/5level-fixup.h: fix variable 'p4d' set but not used
> config: parisc-c3000_defconfig (attached as .config)
> compiler: hppa-linux-gcc (GCC) 7.4.0
> reproduce:
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0wget https://raw.github=
usercontent.com/intel/lkp-tests/master/sbin/mak
> e.cross -O ~/bin/make.cross
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0chmod +x ~/bin/make.cro=
ss
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0git checkout 938dda772d=
9d05074bfe1baa0dc18873fbf4fedb
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0# save the attached .co=
nfig to linux build tree
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0GCC_VERSION=3D7.4.0 mak=
e.cross ARCH=3Dparisc=C2=A0

I am unable to reproduce this on today's linux-next tree. What's point of
testing this particular personal git tree/branch?

#=C2=A0make CROSS_COMPILE=3D/root/0day/gcc-7.4.0-nolibc/hppa-linux/bin/hp=
pa-linux- --
jobs=3D96 ARCH=3Dparisc
=C2=A0 CALL=C2=A0=C2=A0=C2=A0=C2=A0scripts/atomic/check-atomics.sh
=C2=A0 CALL=C2=A0=C2=A0=C2=A0=C2=A0scripts/checksyscalls.sh
=C2=A0 CHK=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0include/generated/compile.h
=C2=A0 Building modules, stage 2.
=C2=A0 MODPOST 86 modules

# echo $?
0

>=20
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>=20
> All error/warnings (new ones prefixed by >>):
>=20
> =C2=A0=C2=A0=C2=A0In file included from include/asm-generic/4level-fixu=
p.h:38:0,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from arch/parisc/include/=
asm/pgtable.h:5,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from arch/parisc/include/=
asm/io.h:6,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from include/linux/io.h:1=
3,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from sound/core/pcm_memor=
y.c:7:
> > > include/asm-generic/5level-fixup.h:14:18: error: unknown type name
> > > 'pgd_t'; did you mean 'pid_t'?
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0#define p4d_t=C2=A0=C2=A0=C2=A0=C2=A0pgd_t
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
> > > include/asm-generic/5level-fixup.h:24:28: note: in expansion of mac=
ro
> > > 'p4d_t'
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0static inline int p4d_none(p4d_t p4d)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^~~~~
> > > include/asm-generic/5level-fixup.h:14:18: error: unknown type name
> > > 'pgd_t'; did you mean 'pid_t'?
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0#define p4d_t=C2=A0=C2=A0=C2=A0=C2=A0pgd_t
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
> =C2=A0=C2=A0=C2=A0include/asm-generic/5level-fixup.h:29:27: note: in ex=
pansion of macro
> 'p4d_t'
> =C2=A0=C2=A0=C2=A0=C2=A0static inline int p4d_bad(p4d_t p4d)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^~~~~
> > > include/asm-generic/5level-fixup.h:14:18: error: unknown type name
> > > 'pgd_t'; did you mean 'pid_t'?
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0#define p4d_t=C2=A0=C2=A0=C2=A0=C2=A0pgd_t
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
> =C2=A0=C2=A0=C2=A0include/asm-generic/5level-fixup.h:34:31: note: in ex=
pansion of macro
> 'p4d_t'
> =C2=A0=C2=A0=C2=A0=C2=A0static inline int p4d_present(p4d_t p4d)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^~~~~
> =C2=A0=C2=A0=C2=A0In file included from arch/parisc/include/asm/pgtable=
.h:583:0,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from arch/parisc/include/=
asm/io.h:6,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from include/linux/io.h:1=
3,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from sound/core/pcm_memor=
y.c:7:
> =C2=A0=C2=A0=C2=A0include/asm-generic/pgtable.h: In function 'p4d_none_=
or_clear_bad':
> > > include/asm-generic/pgtable.h:578:6: error: implicit declaration of
> > > function 'p4d_none'; did you mean 'pgd_none'? [-Werror=3Dimplicit-f=
unction-
> > > declaration]
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (p4d_none(*p4d))
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^~~~~~~~
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pgd_none
> =C2=A0=C2=A0=C2=A0In file included from include/linux/init.h:5:0,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from include/linux/io.h:1=
0,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0from sound/core/pcm_memor=
y.c:7:
> > > include/asm-generic/pgtable.h:580:15: error: implicit declaration o=
f
> > > function 'p4d_bad'; did you mean 'pgd_bad'? [-Werror=3Dimplicit-fun=
ction-
> > > declaration]
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (unlikely(p4d_bad(*p4d))) {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
> =C2=A0=C2=A0=C2=A0include/linux/compiler.h:78:42: note: in definition o=
f macro 'unlikely'
> =C2=A0=C2=A0=C2=A0=C2=A0# define unlikely(x) __builtin_expect(!!(x), 0)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^
> =C2=A0=C2=A0=C2=A0cc1: some warnings being treated as errors
>=20
> vim +14 include/asm-generic/5level-fixup.h
>=20
> 505a60e225606f Kirill A. Shutemov 2017-03-09=C2=A0=C2=A013=C2=A0=C2=A0
> 505a60e225606f Kirill A. Shutemov 2017-03-09 @14=C2=A0=C2=A0#define p4d=
_t	=09
> 		pgd_t
> 505a60e225606f Kirill A. Shutemov 2017-03-09=C2=A0=C2=A015=C2=A0=C2=A0
> 505a60e225606f Kirill A. Shutemov 2017-03-09=C2=A0=C2=A016=C2=A0=C2=A0#=
define pud_alloc(mm, p4d,
> address) \
> 505a60e225606f Kirill A. Shutemov 2017-03-09=C2=A0=C2=A017=C2=A0=C2=A0	=
((unlikely(pgd_none(
> *(p4d))) && __pud_alloc(mm, p4d, address)) ? \
> 505a60e225606f Kirill A. Shutemov 2017-03-09=C2=A0=C2=A018=C2=A0=C2=A0	=
	NULL :
> pud_offset(p4d, address))
> 505a60e225606f Kirill A. Shutemov 2017-03-09=C2=A0=C2=A019=C2=A0=C2=A0
> 505a60e225606f Kirill A. Shutemov 2017-03-09=C2=A0=C2=A020=C2=A0=C2=A0#=
define p4d_alloc(mm, pgd,
> address)	(pgd)
> 505a60e225606f Kirill A. Shutemov 2017-03-09=C2=A0=C2=A021=C2=A0=C2=A0#=
define p4d_offset(pgd,
> start)		(pgd)
> 938dda772d9d05 Qian Cai=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A02019-08-09=C2=A0=C2=A022=C2=A0=C2=A0
> 938dda772d9d05 Qian Cai=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A02019-08-09=C2=A0=C2=A023=C2=A0=C2=A0#ifndef __ASSEMBLY_=
_
> 938dda772d9d05 Qian Cai=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A02019-08-09 @24=C2=A0=C2=A0static inline int
> p4d_none(p4d_t p4d)
> 938dda772d9d05 Qian Cai=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A02019-08-09=C2=A0=C2=A025=C2=A0=C2=A0{
> 938dda772d9d05 Qian Cai=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A02019-08-09=C2=A0=C2=A026=C2=A0=C2=A0	return 0;
> 938dda772d9d05 Qian Cai=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A02019-08-09=C2=A0=C2=A027=C2=A0=C2=A0}
> 938dda772d9d05 Qian Cai=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A02019-08-09=C2=A0=C2=A028=C2=A0=C2=A0
>=20
> :::::: The code at line 14 was first introduced by commit
> :::::: 505a60e225606fbd3d2eadc31ff793d939ba66f1 asm-generic: introduce =
5level-
> fixup.h
>=20
> :::::: TO: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
>=20
> ---
> 0-DAY kernel test infrastructure=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Open Source Tech=
nology Center
> https://lists.01.org/pipermail/kbuild-all=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0Intel Corporation

