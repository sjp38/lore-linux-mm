Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0376B0156
	for <linux-mm@kvack.org>; Thu, 21 May 2015 04:23:29 -0400 (EDT)
Received: by pabts4 with SMTP id ts4so97646181pab.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 01:23:28 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id b4si30507664pdo.227.2015.05.21.01.23.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 01:23:27 -0700 (PDT)
Date: Thu, 21 May 2015 18:23:14 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
Message-ID: <20150521182314.442e9cf1@canb.auug.org.au>
In-Reply-To: <20150521101748.2ff2fb9e@canb.auug.org.au>
References: <20150518185226.23154d47@canb.auug.org.au>
	<555A0327.9060709@infradead.org>
	<20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
	<555C1EA5.3080700@huawei.com>
	<20150520130320.1fc1bd7b1c26dae15c5946c5@linux-foundation.org>
	<20150521101748.2ff2fb9e@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/PGA27bABTNFfhDniUQMN7Vr"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xie XiuQi <xiexiuqi@huawei.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Randy Dunlap <rdunlap@infradead.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

--Sig_/PGA27bABTNFfhDniUQMN7Vr
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 21 May 2015 10:17:48 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Wed, 20 May 2015 13:03:20 -0700 Andrew Morton <akpm@linux-foundation.o=
rg> wrote:
> >
> > I dropped
> >=20
> > memory-failure-export-page_type-and-action-result.patch
> > memory-failure-change-type-of-action_results-param-3-to-enum.patch
> > tracing-add-trace-event-for-memory-failure.patch
>=20
> OK, I have dropped them from linux-next as well (on the way fixing up
> "mm/memory-failure: split thp earlier in memory error handling" and
> "mm/memory-failure: me_huge_page() does nothing for thp").

Well, I didn't get this (or the other removal) right, so I have gone
back to what I had yesterday.  Sorry about that.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/PGA27bABTNFfhDniUQMN7Vr
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVXZX6AAoJEMDTa8Ir7ZwVKFIP/3wwscqe4N0MsOtdahEv5S9H
1abj+vD0nPpaASOzv2VGTWa5/yxAeIA72DfQFwAK0ejBCgZQ4uo2pG87LiHUaO8b
HEuzbLVdyC9vnXD1qQPiB385+BmhYzIpbLe9mMogdDTKnBnMAC0d0CdR3gaLRLlH
ro78yPXwSgpFl0wZiEWj5yzbR/WFD4tEezUYBo1ZvT//MeBQLiISrKccqQcHYKZT
UFrhLnf17D2FFSaWTfUHG1kHI9ldA68ohbbWkgcdR6m022TAV14q1gyAyVl0Fqd7
hthEzvxggH7jhhh3AsdqKUe+Wf/7JVGya22zDXLp/xJrYJUFLoMc5YowjjgZiwsW
N+sHAosN17iOFX7vbS3+p8OjDxhlNXvICPaJFhOjxgYb2fslUGSDTj1UwHfLHPtz
CG35ApBqleiItAZn0nY+UN+Q9yZhcedOaK3DU9FBNIPskPVBdCXP3zBI+oL/A6jh
LNQ0XQNPDXnjyxZ+U5AL9ckX8lXE0Jx60IxYWWRta3TkP8f7TnU9iMFldDDzj6pg
0TycVfpfevWc7BP6098mUkXrgzBBPFGo0tb7s3ixZMcO0ktDHp1d8HVh3QIrs2Kz
8xUEZta6XPUVg+U3iKKiXDtLrsDQhEcgqjPeObQ/GOOcIz2EKVy2OKobu6pHwewR
kkD+eVO9qt5yN06fwASa
=ibIA
-----END PGP SIGNATURE-----

--Sig_/PGA27bABTNFfhDniUQMN7Vr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
