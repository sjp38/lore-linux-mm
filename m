Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 381C3C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 23:30:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBDD620651
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 23:30:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBDD620651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F2E86B0006; Wed, 17 Jul 2019 19:30:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A43F6B0007; Wed, 17 Jul 2019 19:30:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B9668E0001; Wed, 17 Jul 2019 19:30:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id D7FA86B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 19:30:33 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id m25so2435509lfh.3
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 16:30:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=2Xh31uDt4rvWk64IqNBSrMQldztt40TCC7Ojot8d7Oc=;
        b=IXF2XEvlczo+vN3MTF2okB9Kme9/2NqfSVjaYbvAFzIRH9RFBfjt0U8aLJrHfWbiEK
         PzQKZt8PqKqVQV99a4AbAnGz2HiV56I/Abb7lJ8QBP3p/GdhhoLwZcY2Chtvifgu9lx3
         7OA/JmCgr++vZf7yBhgtWyYc+O8z1NTZNIvjfmPQ8zBUSy9tOV9yJ20WRK37W5PTaCEa
         kBdZ7XNlPx6/Nh8jrBXrjE3CRllzm/PkA82TsajmY4QcipKHYA0MDQtANzSvNuXU14IP
         g1XvSfM+e+Y6A5NnNHo16+rhBfiR9q8Eqsusi1NvrQHZAaxfJxsvs28I/fXvgyot51zM
         0h0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldv@altlinux.org designates 194.107.17.57 as permitted sender) smtp.mailfrom=ldv@altlinux.org
X-Gm-Message-State: APjAAAUB8KsuScF6X7qq0S/C5ggohovb+jL5/yL1PLitvkWUSjBOsSoY
	biUYqqL6itVVzo1tMg74BgYnRnhUwbqR24QhhnXsR+fF1fveQ9BsULhO8us/L4IiK/vccita9/7
	cqIza8x7MF5/B72NvPCLR+Nd9z/gavph8fGbjONisUKx19GkujZntkwqfTlQa0pB5Gg==
X-Received: by 2002:a2e:9048:: with SMTP id n8mr3203600ljg.37.1563406233146;
        Wed, 17 Jul 2019 16:30:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCqq9+8UTiRA0x1Y7HaRSMSD9xlye5PsJ5sLllkhsRZYPsnpADBEM6nngibmMl0Dff5gYz
X-Received: by 2002:a2e:9048:: with SMTP id n8mr3203571ljg.37.1563406232123;
        Wed, 17 Jul 2019 16:30:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563406232; cv=none;
        d=google.com; s=arc-20160816;
        b=qQuvWCH+wGAw8aKIHICbL4O0gUWIlcVHFg0dP5wk8sNIeYTjkk/ZN1GV6KbZDYhPbY
         w/pBRE2Xf7eDiMjxTXd/ROVPC/KtH+Mmv5imfSz+7tAIkrqobq8aFsNnvDwAJPISOawP
         ZLJcWp7X+0a2BOX010PmCWWBA3NFeTzJjV+jU8ly9NePuPjJ+7ztmABRHTkXY1D8QSrm
         2PQnf71YgeDUGG0bJwnJLuGIxARAnFPFEyhzMFpcZ4phbPXPvDeE4PXuOpmMU4+/Pjtr
         bLyjxzMK8WFEKDgi59+K/5p0J4KT30H6aoawTMacULOS6O1bKAK/cF66XENZw6KSpnKc
         BE9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=2Xh31uDt4rvWk64IqNBSrMQldztt40TCC7Ojot8d7Oc=;
        b=igGS0LwYlzBkmNaWBTFYiR+i2TnerC51vRGuwpI/U7rBXGWRavk+5Rlav/v4vzTyYm
         cDO2y8cSGYRQPj/R/kJCIpsmU2Wf+XEzzLWsHUTSQ+rsPl1MZm8Pg7i8QA2v2vKvQ8fC
         3CEqqMRSvtJSUMPG3WvTrdoWV5c8axJUJZN4HGpri5JmWLflZO+7iJB/rJcDp0N7tjM9
         RdgcmI+DyQDh1XVAjc40tktpaAvvodBIxdBwmKsCymoBk3ye6I6u/z7Pf9e07wmLAWBA
         px1Fe+nUebaRLlJx24wsriLHfgkUMWIhRy2yE9TPYwGPJZYwzRDxsBNK01ckQ2cryYms
         28HA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldv@altlinux.org designates 194.107.17.57 as permitted sender) smtp.mailfrom=ldv@altlinux.org
Received: from vmicros1.altlinux.org (vmicros1.altlinux.org. [194.107.17.57])
        by mx.google.com with ESMTP id h17si26560970lja.223.2019.07.17.16.30.31
        for <linux-mm@kvack.org>;
        Wed, 17 Jul 2019 16:30:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldv@altlinux.org designates 194.107.17.57 as permitted sender) client-ip=194.107.17.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldv@altlinux.org designates 194.107.17.57 as permitted sender) smtp.mailfrom=ldv@altlinux.org
Received: from mua.local.altlinux.org (mua.local.altlinux.org [192.168.1.14])
	by vmicros1.altlinux.org (Postfix) with ESMTP id 8897B72CCD6;
	Thu, 18 Jul 2019 02:30:31 +0300 (MSK)
Received: by mua.local.altlinux.org (Postfix, from userid 508)
	id 6F6307CCE5C; Thu, 18 Jul 2019 02:30:31 +0300 (MSK)
Date: Thu, 18 Jul 2019 02:30:31 +0300
From: "Dmitry V. Levin" <ldv@altlinux.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Khalid Aziz <khalid.aziz@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Anatoly Pugachev <matorola@gmail.com>, sparclinux@vger.kernel.org,
	Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
Message-ID: <20190717233031.GB30369@altlinux.org>
References: <20190625143715.1689-1-hch@lst.de>
 <20190625143715.1689-10-hch@lst.de>
 <20190717215956.GA30369@altlinux.org>
 <CAHk-=whj_+tYSRcDsw7mDGrkmyU9tAk-a53XK271wYtDqYRzig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="eJnRUKwClWJh1Khz"
Content-Disposition: inline
In-Reply-To: <CAHk-=whj_+tYSRcDsw7mDGrkmyU9tAk-a53XK271wYtDqYRzig@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--eJnRUKwClWJh1Khz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 17, 2019 at 03:04:56PM -0700, Linus Torvalds wrote:
> On Wed, Jul 17, 2019 at 2:59 PM Dmitry V. Levin <ldv@altlinux.org> wrote:
> >
> > So this ended up as commit 7b9afb86b6328f10dc2cad9223d7def12d60e505
> > (thanks to Anatoly for bisecting) and introduced a regression:
> > futex.test from the strace test suite now causes an Oops on sparc64
> > in futex syscall.
>=20
> Can you post the oops here in the same thread too? Maybe it's already
> posted somewhere else, but I can't seem to find anything likely on
> lkml at least..

Sure, here it is:

[  514.137217] Unable to handle kernel paging request at virtual address 00=
060000541d0000
[  514.137295] tsk->{mm,active_mm}->context =3D 00000000000005b2
[  514.137343] tsk->{mm,active_mm}->pgd =3D fff80024955a2000
[  514.137387]               \|/ ____ \|/
                             "@'/ .. \`@"
                             /_| \__/ |_\
                                \__U_/
[  514.137493] futex(1599): Oops [#1]
[  514.137533] CPU: 26 PID: 1599 Comm: futex Not tainted 5.2.0-05721-gd3649=
f68b433 #1096
[  514.137595] TSTATE: 0000000011001603 TPC: 000000000051adc4 TNPC: 0000000=
00051adc8 Y: 00000000    Not tainted
[  514.137678] TPC: <get_futex_key+0xe4/0x6a0>
[  514.137712] g0: 0000000000000000 g1: 0000000000e75178 g2: 000000000009a2=
1d g3: 0000000000000000
[  514.137769] g4: fff8002474fbc0e0 g5: fff80024aa80c000 g6: fff8002495aec0=
00 g7: 0000000000000200
[  514.137825] o0: 0000000000000001 o1: 0000000000000001 o2: 00000000000000=
00 o3: fff8002495aefa28
[  514.137882] o4: fff8000100030000 o5: fff800010002e000 sp: fff8002495aef1=
61 ret_pc: 000000000051ada4
[  514.137944] RPC: <get_futex_key+0xc4/0x6a0>
[  514.137978] l0: 000000000051b144 l1: 0000000000000001 l2: 0000000000c019=
50 l3: fff80024626051c0
[  514.138036] l4: 0000000000c01970 l5: 0000000000cf6800 l6: 00060000541d13=
f0 l7: 00000000014b3000
[  514.138094] i0: 0000000000000001 i1: 000000000051af30 i2: fff8002495aefc=
28 i3: 0000000000000001
[  514.138152] i4: 0000000000cf69b0 i5: fff800010002e000 i6: fff8002495aef2=
31 i7: 000000000051b3a8
[  514.138211] I7: <futex_wait_setup+0x28/0x120>
[  514.138245] Call Trace:
[  514.138271]  [000000000051b3a8] futex_wait_setup+0x28/0x120
[  514.138313]  [000000000051b550] futex_wait+0xb0/0x200
[  514.138352]  [000000000051d734] do_futex+0xd4/0xc00
[  514.138390]  [000000000051e384] sys_futex+0x124/0x140
[  514.138435]  [0000000000406294] linux_sparc_syscall+0x34/0x44
[  514.138478] Disabling lock debugging due to kernel taint
[  514.138501] Caller[000000000051b3a8]: futex_wait_setup+0x28/0x120
[  514.138524] Caller[000000000051b550]: futex_wait+0xb0/0x200
[  514.138547] Caller[000000000051d734]: do_futex+0xd4/0xc00
[  514.138568] Caller[000000000051e384]: sys_futex+0x124/0x140
[  514.138590] Caller[0000000000406294]: linux_sparc_syscall+0x34/0x44
[  514.138614] Caller[0000010000000e90]: 0x10000000e90
[  514.138633] Instruction DUMP:
[  514.138635]  0640016e=20
[  514.138650]  b13da000=20
[  514.138663]  ec5fa7f7=20
[  514.138676] <c25da008>
[  514.138689]  ae100016=20
[  514.138702]  84086001=20
[  514.138714]  82007fff=20
[  514.138727]  af789401=20
[  514.138740]  f05de018=20


--=20
ldv

--eJnRUKwClWJh1Khz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJdL6+XAAoJEAVFT+BVnCUItv0P/RQl7zn0jCq+B4G33r61CH0f
MM3lOaEkCdZV3KhE/13PJWKFSRP2b6rh0k95kDhUNnPdItg3b4xEwHuMwHKzyzCs
RdDrQ5ISjKrSwGJqrAywjpEX5Wf7JnUS98muIIWgcrfA3M3HzQMgKmVIna3SstVD
ZTXmMFjnnuGSKI5xA79VBve9xPbDDkF0cPTrRIkXwk3HzTrQi9NKwj+VyFnzvri/
vXBb8oQ5OJymQryUnoeVxs2MmraXPotL+M/8krsZIoAuaK4IMFiFh5T7ZBVigqFv
934gPFbRyRdErsuiJo6PMqJUay39etJBifC4sem9zw6NcP+sSMB5L8EABFkWT0j+
VuW3foMsOIoH/+8dbYsdTsw4RHpXv6WeUwrNLXZLCWACt2M/m5wBlrBFf0NMbRW4
LtWcIzy4IYfmmUiKrVfAUNv3Yx991ah+QTeq871+Wsy2irvJuE7c4lfH6RxCOjKT
CrtF6oqFcOFHZRfl4JSzc2dbd/tepmNwonQeO6WXwruxRoMI2NhL350ijQJjkXOP
qhz/qutyUOk662ZP30+j0G1iT4TGERug8SLaI11eEjTpqIMUQMtPa0ATsoIkR/+x
S1637lihAJh2d2ik4os1nLjDNakmc6TMgS0KcDXhfo219fWAD5YrgmQD8g7fUnLp
4bgJDOaNpCu6rzRT4WY4
=3YbY
-----END PGP SIGNATURE-----

--eJnRUKwClWJh1Khz--

