Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA34FC43387
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 20:14:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89C8221874
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 20:14:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89C8221874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19C628E0107; Fri,  4 Jan 2019 15:14:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14B028E00F9; Fri,  4 Jan 2019 15:14:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 062AC8E0107; Fri,  4 Jan 2019 15:14:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id CEA848E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 15:14:49 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u20so45635009qtk.6
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 12:14:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=WQdigzsL09FgL/39VMNAGDVRAY4BGg24VG2c29+PPu0=;
        b=psL8RrsYLFqa/gXCZUBNEcMvszAbGfRoxZebZy+supGfnOoVc+gZ2ACoRGqjDkidtK
         bAhlIKDT6ys/rF9h2RYIBqBSy/yUuB+4/5TNIQMVOqM0S7f9pZAGsR1HJ1RIYHfkzKk/
         3LDOnP1pqhA+pG/i35CeNmXpb0+lUCjzE+vi5+p64DPspF/stON6yPLbQfrVEiYTPjZH
         iBwuHxvNCUdAwS8Ct2q/4y0ByXh7FunoUxKbuF56zbzuXJlmwEMF+ecLaGUfxo5iUEFR
         UCdPxcVGRHWt2tfJvAyjwlKgMnR/M1/ABleXOLBgT5qSWRLxIZmmywVHxmxQAwjQewCU
         8dPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AJcUukdO3QaAOyRswj82dqhTnMcJ3rBPZ92SjfMwbbpmgVglH/pz1gKu
	Gf1S3y79FoUy/8au2ZBpO9boh/4updksn5+91nn5OQCaggdMVfA7D4hnViWS6JKH3ETWl0ZgtMi
	ZPgubN35ByODHHb1GbVuRD+tQZGKOdS8XgVu5eTPV3ZOJvUG1VnVUhiGy3Y+2kHZYTQ==
X-Received: by 2002:a37:90c3:: with SMTP id s186mr48644395qkd.339.1546632889575;
        Fri, 04 Jan 2019 12:14:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5PV/woM+GlI6cj9iGZA9HzmTahYgWUzC3lh6Y/y0A9r/5hIxGHLruNGJRAPBp9fIXzN0dk
X-Received: by 2002:a37:90c3:: with SMTP id s186mr48644355qkd.339.1546632888856;
        Fri, 04 Jan 2019 12:14:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546632888; cv=none;
        d=google.com; s=arc-20160816;
        b=0EwDNI4jzrvEhqe3IqXWnW27962QlNVXByhs+63LTcHuQUsVu1pJ+4ZE0tfleFGA8k
         iOSPbP5UpkO0IorRi/8PDPI+SY63FYbxvxTbMD3jmzVj3WyHpZ5NrgXb8imcnh/9fRWq
         kERnXngJt8C+kh8BcqVzGQlWDs3ydbKtSLO2H9WgP3JvBqzhHy9T00N9F/ByK3Ica6LH
         mwBPw6fk9rwEw0If717qPJwZQLbFhR8F6Nvspp9ybIus6AEC4P7anCRSJFcsF249Traf
         eFNpqbN5a9F5WyLRKSLm7Fy3IQTM1aGMSzLKtAtqDgzWqpJPiGbWZaoKqZ+UjMf92SH7
         nQnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=WQdigzsL09FgL/39VMNAGDVRAY4BGg24VG2c29+PPu0=;
        b=u/ec6bqNtYprVrjRi4Y1WXIqSQ99mAfx4zO/bwZmbyCNdZIwt0s+FLWmKC8l+VSDPx
         xun1v5vpo5JN0Vxpsl6miNaQFtHeLhusPXeVLLFZDRJx/ifoEUh8HR9hFJWW9jJU1sSY
         BHZevfLcv4SV2OImsxlVEK55/BvPuSUyTMgLUs27Cup0mvjKZ6SupgTuW+OE0JdHCyCe
         eEMf1fNc4nIHeoHUaqRp2JrloUND0IjuMkbuRU4jCx/TYpxSzOlRqM0lPancFRlIX/Xa
         ruA2v3Dzjl4cU4cfcz2c0l547KX8BMyfAkwKUKMjUG+qFfw5Udb92BvvDEJCG3jnKGKj
         qzag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id a31si954905qvh.91.2019.01.04.12.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 12:14:48 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gfVrh-0004JB-JK; Fri, 04 Jan 2019 15:14:45 -0500
Message-ID: <a8e412e9e0983b380983099af9a90b9760f0edae.camel@surriel.com>
Subject: Re: [PATCH] fork, memcg: fix cached_stacks case
From: Rik van Riel <riel@surriel.com>
To: Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>, Michal
	Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org,
 linux-kernel@vger.kernel.org,  Johannes Weiner <hannes@cmpxchg.org>, Tejun
 Heo <tj@kernel.org>, stable@vger.kernel.org
Date: Fri, 04 Jan 2019 15:14:45 -0500
In-Reply-To: <20190102180145.57406-1-shakeelb@google.com>
References: <20190102180145.57406-1-shakeelb@google.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-12qNsl9snEwifMAZ7N/9"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104201445.8EiQ6qaeMk-e41LLyq-HPEfYtz45pMfp9ebcgqdN5Fs@z>


--=-12qNsl9snEwifMAZ7N/9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-01-02 at 10:01 -0800, Shakeel Butt wrote:
> Commit 5eed6f1dff87 ("fork,memcg: fix crash in free_thread_stack on
> memcg charge fail") fixes a crash caused due to failed memcg charge
> of
> the kernel stack. However the fix misses the cached_stacks case which
> this patch fixes. So, the same crash can happen if the memcg charge
> of
> a cached stack is failed.
>=20
> Fixes: 5eed6f1dff87 ("fork,memcg: fix crash in free_thread_stack on
> memcg charge fail")
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: <stable@vger.kernel.org>

Good catch. Thank you.

Acked-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-12qNsl9snEwifMAZ7N/9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlwvvrUACgkQznnekoTE
3oNgnAgAq6FDLf8JFXdxaI5a/OrCOHkZMEgApfIj4niwaw4iM9qXvM5krVAQ2X+r
vPFrxY7h0mcDljuUAuKxMoBbKnBVHZM72iLk/iD8T2mXT43aEtLsDYM/Nn/B6ric
uOcG+ScFutfcfOoF0B62pPFIQ/WjA9EY5Oc5yx19lRe1/tZpatwHZnOmCbQa7xvp
EGNr3C7dkz4xmgAOEv9k2+yPqgM1AstekA85rQBiQWY/8pNx+vAxOy97UKrfJa2Z
C3Ar/TgmuN2xUwCtPWNAIt4tt3tND5rtdgoczUu5duORPLPpCqlgPwQcizLq85bI
p+DF4agefINLKG1AnjiNta1jjpiACQ==
=tR4H
-----END PGP SIGNATURE-----

--=-12qNsl9snEwifMAZ7N/9--

