Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBD9AC282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:03:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82E662177E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:03:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82E662177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 257BE8E0004; Mon, 28 Jan 2019 15:03:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DE1A8E0001; Mon, 28 Jan 2019 15:03:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A7E58E0004; Mon, 28 Jan 2019 15:03:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1EDF8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:03:32 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id t18so22046614qtj.3
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:03:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=4JPUVXt2AnmUGHhYL0L59IVWanFzQLuUqKIUT03lwS0=;
        b=SssylYtaYf/QEtB38RZW1VFADHLYXr8vcZvw9I4Xxf1JvgvQ1zjT9sVkwOWGxZmJiA
         osmG1fMLApx3PnDeOlyVtl6aK28+Z3M65dEVvurzpLribTiuHgAuqSL9SiOldo1ia88k
         FkBtIn4jn2DCUH4G5XRbcy0dlBO/vfcj3LVDTJRXetgmxxXhQ+jg5h0Dh1+dGKv9iedt
         Z0CHW+fLJM1dffLw0BHs8m+sb4KN5ofpIVJjnWqDOs6nPgVJ7ZHy/8XW0f7uPSBTcQ5H
         XT6uma0abL1adTn7/yGXUKD5hGfO1CNPBHT1xB5/MUyV2QsQ2C6tx2zN4oSnG9WBpMRx
         t8Rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AJcUukfyBV05Bt0PeueYzVgxwM/+3XQTm49YD9pXu51dMMCrNEzJaik9
	LVb5RAY9iyhPWXxN2WfQQPxwdiIYxoEQQ/ct/3tWtnVs9MydOiS9I7C2iYR+UOGR1QN3BP1TuAe
	6BaXmryCtd8JyOUhqiPEunpiwmqaPCxBRhlOETj+9rRh/Lj4Kdp3IuEsN9624qAH4mQ==
X-Received: by 2002:a37:c946:: with SMTP id q67mr21455813qki.145.1548705812651;
        Mon, 28 Jan 2019 12:03:32 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7JZQSA/IqBd8Kd6Xw9zBaL2/IXejg6zqgdEw32CveS5Kf729FVa9kbA1eP0QbIvAWB50pj
X-Received: by 2002:a37:c946:: with SMTP id q67mr21455793qki.145.1548705812288;
        Mon, 28 Jan 2019 12:03:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548705812; cv=none;
        d=google.com; s=arc-20160816;
        b=vHC2/u3jXtBdXiQkwZEOjvZoGSiPO8BYqEzL2rzhyOBJ9W+eHp87KH5SePcEqAaXE1
         k4nczWZcaAnGitoNmMUgr2wsGfFFXNz9Bs9WI5G6DS19oni9J8sAK4+dnth/KNH4C1+P
         K8uQEvn2IRnomI73JZZBLTyLejKxzr3+al/WFPQTII830JtveK2SXJGRWdPvp/lGPn7B
         J9a2EVVdJMcVey3FWHNMb3WhYBDug4VimuH3njAWTQwF6BWohStlVYQGH7cyJqKxM3/G
         YZmVSAuXLby9XU3btj1oAKn0F0sW6VaKAiC8CpHR2C5+EGGxje+EDcN9yqZ03E2dPlYz
         NL3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=4JPUVXt2AnmUGHhYL0L59IVWanFzQLuUqKIUT03lwS0=;
        b=ag5fKyx9xMXAtB7Hi8K8Fb0nx8ckY9F1P+lFc6tdchGhc9LRAVAhIFFXob4pmuPqjS
         bFLdEe1R9ykeynIwpDa8Sps/fc56+Fii9vdkN08au2Gru6HqBGxn4xgCmAba4Bv90gY/
         m31EhbLU1SUJKLjuUdO5vuUcWXG181d7RMXseI7rtDztDT3zFKmBocU9i9C9cicwCqPI
         Q0+Mgy06t0yP1EAwMKDFhh1z9xmYh9JIJlOGdtHL1FaUjQu2ZjwfkSrnLMVlo7MCjvRE
         XdXlHVlMf/eaKeCkXL9jYkfu0doKPltgs3myG3bSxBtoQuQEfpSlNw1D5liHYkkCk9Hz
         o3yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id o3si2936644qvl.30.2019.01.28.12.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 12:03:32 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1goD7w-0006yz-Lt; Mon, 28 Jan 2019 15:03:28 -0500
Message-ID: <8ddf2ea674711f373062f4e056dd14fb81c5a2fe.camel@surriel.com>
Subject: Re: [PATCH] mm,slab,vmscan: accumulate gradual pressure on small
 slabs
From: Rik van Riel <riel@surriel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, 
 Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <clm@fb.com>, Roman
 Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>
Date: Mon, 28 Jan 2019 15:03:28 -0500
In-Reply-To: <20190128115424.df3f4647023e9e43e75afe67@linux-foundation.org>
References: <20190128143535.7767c397@imladris.surriel.com>
	 <20190128115424.df3f4647023e9e43e75afe67@linux-foundation.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-nGE8UQknFPEiL8nfsYnb"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-nGE8UQknFPEiL8nfsYnb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-01-28 at 11:54 -0800, Andrew Morton wrote:
> On Mon, 28 Jan 2019 14:35:35 -0500 Rik van Riel <riel@surriel.com>
> wrote:
>=20
> >  	/*
> >  	 * Make sure we apply some minimal pressure on default priority
> > -	 * even on small cgroups. Stale objects are not only consuming
> > memory
> > +	 * even on small cgroups, by accumulating pressure across
> > multiple
> > +	 * slab shrinker runs. Stale objects are not only consuming
> > memory
> >  	 * by themselves, but can also hold a reference to a dying
> > cgroup,
> >  	 * preventing it from being reclaimed. A dying cgroup with all
> >  	 * corresponding structures like per-cpu stats and kmem caches
> >  	 * can be really big, so it may lead to a significant waste of
> > memory.
> >  	 */
> > -	delta =3D max_t(unsigned long long, delta, min(freeable,
> > batch_size));
> > +	if (!delta) {
> > +		shrinker->small_scan +=3D freeable;
> > +
> > +		delta =3D shrinker->small_scan >> priority;
> > +		shrinker->small_scan -=3D delta << priority;
> > +
> > +		delta *=3D 4;
> > +		do_div(delta, shrinker->seeks);
>=20
> What prevents shrinker->small_scan from over- or underflowing over
> time?

We only go into this code path if
delta >> DEF_PRIORITY is zero.

That is, freeable is smaller than 4096.

> I'll add this:

> whitespace fixes, per Roman

Awesome, thank you!

--=20
All Rights Reversed.

--=-nGE8UQknFPEiL8nfsYnb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxPYBAACgkQznnekoTE
3oN05AgAngaeuhkjCHuyhq8zG04YT0jvQFZoWcNexTYi/rVLmxraUqdOJhpgIvFl
YMidQJwFi1448jznIdXf3/dgyvbu5JI+JoyhwlfmLv8wyHGWo59AfSkCT8bAPKR5
qHFY0TQCoOM/QyIW5Qeew5iHjNxceZfLvXNQVlt02jPoR5ysBWC9mudPYHAcTggZ
4fH8MkS8ukd8ykvx+WbEoO8GzTQrqwcc8bvPsl+mq7I+H2V6J1JhzQON3BSYZnNG
1SWKuzYdAYP6pxUXYweEl2YkTm4KtNgcxLPF3T8h99Gwa1/Nb9SvWSp6oZB4s9UD
SWeY7MLKfnBK5aox7F+ilHrcYJrMfw==
=O2ss
-----END PGP SIGNATURE-----

--=-nGE8UQknFPEiL8nfsYnb--

