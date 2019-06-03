Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BFF3C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:40:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57E9B27888
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:40:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="tzn4pUMi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57E9B27888
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01B6C6B000A; Mon,  3 Jun 2019 10:40:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0E816B000C; Mon,  3 Jun 2019 10:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFDE36B000D; Mon,  3 Jun 2019 10:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A8C606B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:40:08 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u1so8306699pgh.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:40:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=hPsNQnidYq+BQl/NNJgUFJGoiM8pu0dcJ/loGylQo0Y=;
        b=L6zDQpWu2wzv9tWr3YqU2rCDuS8hqzN6zZZ9fMdxolmEJa4OAPOgH/zC4+MY1GUok0
         pfLQWf6aB7JodSqdeq5kz8pOothBgjiTX68B24F42in9/rzoBlwMKY0I4uE9U9WPTtjj
         xPGkkFzooFufauFeYyJrYftw9ybpd/RVUcvujjBosrE7kqnyW555zfGMsi3yJcZ3PE3v
         Ot8tVQVetCQmv803tyI+gTkq2SmZOqkK1XqwLlZ7pfYxks0Sdde0aYCq8Jmgt19XvgUX
         ibiKS4aCt/krPCXZO3QrDgwqwAw9dE6VKz0VeaRXjLeilqOcCC1+W8YKrj2pJdG0Ncmb
         UhfA==
X-Gm-Message-State: APjAAAW5aqUPa/byFngVuJQ6m3S41btLwdF+9PKuBdFXMjyYVGAOT97U
	2o05CsBxJWmDJpDjsNkidF++5hQiHHwsTVxB2iugVPvam7QGuTTjiWGt5LMU/GaMSKCNrd7hPry
	1VrEIYsV2dK+O5WeEte2htXBtofkx8zG44bll2dL/PjO229gzyCV/VR2DfVtFPqrDmg==
X-Received: by 2002:a65:6116:: with SMTP id z22mr28705658pgu.50.1559572808334;
        Mon, 03 Jun 2019 07:40:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPLZJqfMu/9dB16ulZsOUh/cslbxC90tYNFSO5OLMgO9QTZ1ByWK/RYKswcWqGZ1sZhNV+
X-Received: by 2002:a65:6116:: with SMTP id z22mr28705549pgu.50.1559572807260;
        Mon, 03 Jun 2019 07:40:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559572807; cv=none;
        d=google.com; s=arc-20160816;
        b=I7+T4zMTW8LTchuqesA9pfRdjYzi9GoR8mmtiHw2tMEAxS3AdYhdezKenLPYToq7KU
         BKTnRlrstHS443KMzyWD+ZjZSdPMAPLx65AxsdcnKcCpG33rNrcnGta0ejYTe41L/b2J
         DHnQpgTCL93q8x7f96/QAiRB14xz4/A5ub8wi7ndDaIT1zoJyuoRzsQB/WgjnU4VClfv
         6OmMqySPgaxjQGO/NXQ04Ua/XLHAcZtAKO2m8Jjn5yYb280vDnHSacMAHxSCnTlb/0bU
         1rIKxvXyYsBcc49QCIJsm3HKwRIJVrSSwqZ/Yqsgh/o6FgJnrrpsn6t/wsLx3gN1GK8g
         6/5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=hPsNQnidYq+BQl/NNJgUFJGoiM8pu0dcJ/loGylQo0Y=;
        b=Lakp781IK8jfRQKzouJdbShPBkNDvcMMps6jaQusxdScrnp3j+gf2U+L3sml7xWWsD
         NXVhLgvcbQ27Ic6H90h7OPxZvnXjLVoK7FXfTDfMIXQ8APa+6MGb62HJ2HeE2mwtnMwJ
         LbVWID1qIyCviblzIEkh2/Y7AzDK4jS6pCvMwHzQMwP7EYXXALX5WD9SHSZfMzpxOP5E
         B37qNuxSMpcWlZU6qSAVeVpMdbT0ynRclNCD5f4kCm0yYOpTgtzxHpxQkZlv6xXfoa/K
         XsE0skynhjXUKpxGB1LUVaLJHF6aBGOqtjulCHR2w9syEalEAO1PGehdirHMrAKcIsv1
         Xjyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=tzn4pUMi;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id f63si10807839pfb.86.2019.06.03.07.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 07:40:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=tzn4pUMi;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45Hd4f2zbfz9s1c;
	Tue,  4 Jun 2019 00:40:02 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559572803;
	bh=FmOgiY6lTWDTCTs9StTg9VBetPqLMyHfqz6jDfrLEw4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=tzn4pUMiSu0BF5kUDplr3AltOVKC3qEPEVi2vSFc0pduscleqgcb4mQ4knMeVZlQ0
	 +AI7Tw85ErOshOMcx5omQ2KQEF60D0UUSz9WusycR48ts+ptuMuKFl2BZwhwd8mkv2
	 PTQ611rzC32q9O40FUmpPaXdPUqHya2oQrM+p1/wx0RebbbFd8sQobSwAZUwmXAnpF
	 ZGvdvEeclib+ja0S5JzavMHBg+gKnMr922Wo3hiQNmLRS3Ie/PtG94WrT1BP6Pnsc/
	 JOdL61En/qVH8F7a6x6l9LDibcVMoHu+p4EDM3ksvoE+QnhrrnLae73PwCNC/iXqC1
	 BbiVcLGaabBjg==
Date: Tue, 4 Jun 2019 00:40:00 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: Uladzislau Rezki <urezki@gmail.com>, Andrew Morton
 <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>,
 "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>,
 linux-kernel@vger.kernel.org, Hillf Danton <hdanton@sina.com>, Thomas
 Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, Andrei Vagin
 <avagin@gmail.com>
Subject: Re: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
Message-ID: <20190604004000.0d6356a9@canb.auug.org.au>
In-Reply-To: <20190604003153.76f33dd2@canb.auug.org.au>
References: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
	<20190603135939.e2mb7vkxp64qairr@pc636>
	<CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
	<20190604003153.76f33dd2@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Hhpt4L1s=8zO1hfZdUUFFal"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/Hhpt4L1s=8zO1hfZdUUFFal
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, 4 Jun 2019 00:31:53 +1000 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> Hi Krzysztof,
>=20
> On Mon, 3 Jun 2019 16:10:40 +0200 Krzysztof Kozlowski <krzk@kernel.org> w=
rote:
> >
> > Indeed it looks like effect of merge conflict resolution or applying.
> > When I look at MMOTS, it is the same as yours:
> > http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=3Db77b8cce67=
f246109f9d87417a32cd38f0398f2f
> >=20
> > However in linux-next it is different.
> >=20
> > Stephen, any thoughts? =20
>=20
> Have you had a look at today's linux-next?  It looks correct in
> there.  Andrew updated his patch series over the weekend.

Actually, this is the patch from mmotm (note 'm'):

From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: mm/vmalloc.c: get rid of one single unlink_va() when merge

It does not make sense to try to "unlink" the node that is definitely not
linked with a list nor tree.  On the first merge step VA just points to
the previously disconnected busy area.

On the second step, check if the node has been merged and do "unlink" if
so, because now it points to an object that must be linked.

Link: http://lkml.kernel.org/r/20190527151843.27416-4-urezki@gmail.com
Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
Acked-by: Hillf Danton <hdanton@sina.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Joel Fernandes <joelaf@google.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Thomas Garnier <thgarnie@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmalloc.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

--- a/mm/vmalloc.c~mm-vmap-get-rid-of-one-single-unlink_va-when-merge
+++ a/mm/vmalloc.c
@@ -719,8 +719,8 @@ merge_or_add_vmap_area(struct vmap_area
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
=20
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
+			if (merged)
+				unlink_va(va, root);
=20
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
@@ -746,9 +746,6 @@ merge_or_add_vmap_area(struct vmap_area
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
=20
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
-
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
=20
_

Do I need to replace that for tomorrow?
--=20
Cheers,
Stephen Rothwell

--Sig_/Hhpt4L1s=8zO1hfZdUUFFal
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlz1MUAACgkQAVBC80lX
0GyODwgAhFRY7MDp6PN5rHGvLRcgcl0R9opYG6WWuR5pAkl9A7RGR/6BDDLm0ZVu
YvumuExfm9Z4XFQkdAqX3yPw+Zt7Y1fLTyY7G8obyw4D+L5/DbktmCKqWMHMO4OZ
iVeW4LyAGfY+t/XFu2By/hPZuIUXnjL+zWP5hW3q+bI0Kzy028LnAEcISuuMxSY4
6ePXcA4eOZZgwAn60poxjWOIgpiu13CTjEsK9/FH/kDbF+bghqvKyI7q09DcBKkm
BSTTHiXPPXCxAjFve53BBQc418H2ZZ+j0uTWZBfsjRWpOETHafQYnZAXwVl7GHaF
L7E3xO/wVQbdCMyaKMbdh3Io4lmHZw==
=/lGE
-----END PGP SIGNATURE-----

--Sig_/Hhpt4L1s=8zO1hfZdUUFFal--

