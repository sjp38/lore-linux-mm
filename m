Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 774FEC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:34:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C77C2171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:34:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C77C2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEF058E0003; Mon, 28 Jan 2019 15:34:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9EF98E0001; Mon, 28 Jan 2019 15:34:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8D448E0003; Mon, 28 Jan 2019 15:34:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD398E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:34:07 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w15so22072579qtk.19
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:34:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=ymGdMmjQsq0XrO1Q3yzxu1Anx6UPObBX8MzxqmY6+9A=;
        b=lN1WXfmryTOFRJ14s4hqvBN8VKiBxyoHyDWkIAag8HOLzfWAri7MV8Kcl5/iYzCt/d
         5JSzgdMwOQeLrGxM70wfU6m0XGqxA0Ycs2uYfnXiwp+nAS5yFSIijuF5QT2OmUflkvJg
         HlxSMCGM3enUH3H/iWWNq5DW8c0BarX21+DU25cTntZavcqUtpJHyVVLTenKwiXcIGsS
         b7z6iQWDnQjgqf7Dsjao8zsdMF19V/1qd0MDz6Ya/PWdOvuKGbfLlKrXDQxp2iDtPOdb
         0Pl+OKhMfQNiYIkLZnejWwy1LB3B5k7l6S1aFBQxz4RuHGzPvjoQheUYdwdAmHYrxLk4
         W5qw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AJcUukdVBVf1oOAsx9L14ui0It8Tkxlc2ZuGhhtAk3Hnfb2ktQ25Isjm
	pbl8+gpCkPERTPjvL5QdKQiIkZGsVaBoNvqVF/OhhkKyfSYZ03/De7tFVY2YlmxjUqGNCbQ/6Sl
	yD7742gn6fCuDSfDgD/Dfux0sJl+lvaObLVigwzJ0jLrldeNaHkqGwMXA5b9G3XjYHA==
X-Received: by 2002:a37:b201:: with SMTP id b1mr20271086qkf.306.1548707647284;
        Mon, 28 Jan 2019 12:34:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5I3B9hXKuRKRl2Cwd8xPE5TmbMZMj+OQeCENmUK4m6aRtmNzFZjyhiuZJ4r6Lae3moImfl
X-Received: by 2002:a37:b201:: with SMTP id b1mr20271065qkf.306.1548707646857;
        Mon, 28 Jan 2019 12:34:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548707646; cv=none;
        d=google.com; s=arc-20160816;
        b=MRaMrYMGFf7H44SGHhAgpD96cR2byqQfEZb/H4wkK6uubsNgHMwOFu3eZpnr9SOC4q
         cbqEvsZvCIB6AF/VJs3z+onR8VbCW1evlw9gwRTQ6p0z+W6ExjvTIdEy1vQ6pDUhuL13
         6kUy5UoKY624ZEtpomr9pP2wIrKnKmlPvAEs1j7ISSkAqnOLGBBZ/HbGTxvXvTwbNd7+
         X4O6a0IwNUZoqFI6Ji4qWdic1FLJtbsw3gB0nQtN5PRSvIoq1VjS1VTNfQDes6S4B5KB
         w9wwb+4iMXvPVz/mntLXGcHLP1n6YTC3UY+V6z+R02B/xr8GxyXwqjPrV4OIWwuzOb8l
         p3tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=ymGdMmjQsq0XrO1Q3yzxu1Anx6UPObBX8MzxqmY6+9A=;
        b=TrWtOjspFQc9ZyVuOLZbRnFk3nb1VAKk0Ily4DlOcQaAXFSxmaQCXZdAoRsZyqNwg7
         8bH8wVoB0L2tnSbQqIQTftEWdbrK3zwcXwhztt66+BtDd+Em3m/L0oqeXQYsMOccEhIo
         vGcPtsygxn5Aphp67o7ul1iQAMzJv3Vx/JVTxpY+sUyl7JInv+dsvwzBvjKS3/ezsVZF
         yJGIKiEPjfXxjLohNw36T8zlEP4iYmEW0JFBdp3kILcmJx3GlNB3KuJTpqTY5ysnqdNX
         z6kERG7BFDCDU4ABgotTFP3b3/7dC/xGBTw8e57EB9TBLkqsBakSjGEybTt8OyIvaXUp
         F/Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id 41si1556454qvy.216.2019.01.28.12.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 12:34:06 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1goDbX-0007BA-AU; Mon, 28 Jan 2019 15:34:03 -0500
Message-ID: <d4e9359fdb3817bbc2b2c7cea368f8fd0dc7da62.camel@surriel.com>
Subject: Re: [PATCH] mm,slab,vmscan: accumulate gradual pressure on small
 slabs
From: Rik van Riel <riel@surriel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, 
 Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <clm@fb.com>, Roman
 Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>
Date: Mon, 28 Jan 2019 15:34:03 -0500
In-Reply-To: <20190128121028.8ef4c19dd3fd1d60d2e3284c@linux-foundation.org>
References: <20190128143535.7767c397@imladris.surriel.com>
	 <20190128115424.df3f4647023e9e43e75afe67@linux-foundation.org>
	 <8ddf2ea674711f373062f4e056dd14fb81c5a2fe.camel@surriel.com>
	 <20190128121028.8ef4c19dd3fd1d60d2e3284c@linux-foundation.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-rjs2+VELR5ryBMzF0Fbr"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-rjs2+VELR5ryBMzF0Fbr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-01-28 at 12:10 -0800, Andrew Morton wrote:
> On Mon, 28 Jan 2019 15:03:28 -0500 Rik van Riel <riel@surriel.com>
> wrote:
>=20
> > On Mon, 2019-01-28 at 11:54 -0800, Andrew Morton wrote:
> > > On Mon, 28 Jan 2019 14:35:35 -0500 Rik van Riel <riel@surriel.com
> > > >
> > > wrote:
> > >=20
> > > > memory.
> > > >  	 */
> > > > -	delta =3D max_t(unsigned long long, delta, min(freeable,
> > > > batch_size));
> > > > +	if (!delta) {
> > > > +		shrinker->small_scan +=3D freeable;
> > > > +
> > > > +		delta =3D shrinker->small_scan >> priority;
> > > > +		shrinker->small_scan -=3D delta << priority;

When delta is a non-zero number, we subtract (delta << priority)
from shrinker->small_scan.

That should happen every time delta >=3D (1<<priority), which is
4096 for DEF_PRIORITY.

> > > > +
> > > > +		delta *=3D 4;
> > > > +		do_div(delta, shrinker->seeks);
> > >=20
> > > What prevents shrinker->small_scan from over- or underflowing
> > > over
> > > time?
> >=20
> > We only go into this code path if
> > delta >> DEF_PRIORITY is zero.
> >=20
> > That is, freeable is smaller than 4096.
> >=20
>=20
> I'm still not understanding.  If `freeable' always has a value of
> (say)
> 1, we'll eventually overflow shrinker->small_scan?  Or at least, it's
> unobvious why this cannot happen.
--=20
All Rights Reversed.

--=-rjs2+VELR5ryBMzF0Fbr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxPZzsACgkQznnekoTE
3oOmVwf/Y6GZfr1jizlPlmJ8N8/biC88i2jgOJ0lcwGiQayXBu5E3OdH66QhVzi8
RfXbwYurPgoS27JZUmDc1aRuxj6Ueb6YyeJ3pAM4G4pa4TVTM/yoTp9h1JVGFiGK
+82nTKdbHtiRabzwGoE0bHx/DriKGNEKzHEus6ikrj2SSCa7rFJ//3MEIBKnVoT/
ua3diiob0opvUrVD1oU+Qr87yQtG/Fh4CgS4CF+oTCsZspNsRTXknqWHVyF7S0W6
i/LasJK4iTZ5toDtTcBeqYJS9VpbEK1UiAw6LSzJoE+Js2Qkr4CX3euBe6fvszdd
XJ0O8eEdqfG/oDytFji+LSmEeRu0sQ==
=VeYE
-----END PGP SIGNATURE-----

--=-rjs2+VELR5ryBMzF0Fbr--

