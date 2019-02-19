Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CFB6C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B3062147C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:31:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B3062147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88C1F8E0004; Tue, 19 Feb 2019 12:31:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 812228E0003; Tue, 19 Feb 2019 12:31:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B3088E0004; Tue, 19 Feb 2019 12:31:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F34A8E0003
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:31:17 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k37so20625396qtb.20
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:31:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=JfAbn7URI4XKUXlOlR+nmdBhUcAX5rxFO4+plh1nF4E=;
        b=MPXKlxnGYhkOZtK+4xqhvP4F7DtTmsmBEs8jED1anREhqNHyUfYj1+HpiILK0pPWve
         fkNDNkUfLVDjPyEm3chK1pJpKaeHZYC4aZOLZ/RUPefAdiZx0JmS3iIuLgLvTnPX9SYH
         U2YPjjd98xr7W55jphhwIkbyNsY4h1GOrIrQhgsaVwNsy+y6O8kwI1k9wvFJjU4RSDzZ
         0MZKTPorQdRM5QUJA/5nbnSHgo7ltEAUhtaYwtOrFk806vUs2TtcY+d5gbubhnimIKNI
         qUBZcY5Sc/Uki7h4rP16DggLWeEcL9s3CIgLsPNGDRWZ4ODG2cGjk7SX+8cpBCuv46q6
         6KDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAuagV4CRiePrj0h7PYP+CJo9A+r2ocAQNBRU9lXcO+2TUpv5v73k
	b/WvNYnv8mU4FBgdLFKFvgwsy5a+KhatUtajDNeP1ECOQnKWPzOR5sjmQJhItu9vV2NCqOXHgLP
	+tTAKL3Os96RSqrYFHzxnII+hWNDTFmDMk8jUmAREalHp9AI7b11SN9YxX85bjqWp8w==
X-Received: by 2002:a37:9d96:: with SMTP id g144mr21677791qke.192.1550597476994;
        Tue, 19 Feb 2019 09:31:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYkJUuueQbASQNrwEc44C5YyEp31NLrINjG7bFb7UUGkXwCaymuxjrTV6ztUwcXyZPgk2VW
X-Received: by 2002:a37:9d96:: with SMTP id g144mr21677752qke.192.1550597476459;
        Tue, 19 Feb 2019 09:31:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550597476; cv=none;
        d=google.com; s=arc-20160816;
        b=Z0G9oG5qvLbZ70MsP3Ns8ZGABecFXqMfDyvnSG6zPoz2GgIvzPQO4O+5b4x881M6+I
         5/Urm3ghKPF9nbtft1pOGwKtvhFgzm/qj84hNxqUB0QBfi/aoGSnSpAlnOwF9JJpzC5j
         pcFdANWApqhV/VBry8Wu3u4t+erEA/QQj8R60erswCCncLkOIz2kulnoD12JKTB7ojpZ
         WQBbgl6JNl4boH6XOQT1Lhc9Ba3ZXTH91jPp0Hj0Vi7tDPk9CZA8J0jp1E4oH3pF4zkc
         eS3799z16dfQrZSFEQpjQfcChLl5w6+fLxmlBsKkfujwmCV6XXScs3O4YDll4UepQVvI
         TlRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=JfAbn7URI4XKUXlOlR+nmdBhUcAX5rxFO4+plh1nF4E=;
        b=XFkFqqPQ7cPRswbZe/5DmE5TxB7dd0gruMS7m/IoDqn7tYJeS+RlGArKGEkjxD/t1N
         9jXt398++VUkVr67LFdO467aaGyvd1KHSSz3Ogzh+lROy6oxkxp1Cc5bzjPyy5NH7K3L
         f0QVXJJ/VPs/8uqP7oObIWpAOrsvYNAXG7WKkhLMftfF+Xuy7cQvbzzCpX0Is0HkDsAm
         qgeAf9QeT2fhWmoDv7RDJ1s0DLQJwDgVjUgw4DKgVJDuTsQKgUjoSH52ImPfMGUXuXYD
         HSaadm3XSlcUvDR/GqR8KC11x9ZP/8Y46eNqE8I7j9lP/LsfOcSi4LDmkCZwg+zh1eCX
         hjVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id n28si1570988qtb.353.2019.02.19.09.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:31:14 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gw9Ec-0005jj-VB; Tue, 19 Feb 2019 12:31:10 -0500
Message-ID: <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
From: Rik van Riel <riel@surriel.com>
To: Dave Chinner <dchinner@redhat.com>, Roman Gushchin <guro@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
  "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org"
 <mhocko@kernel.org>,  "guroan@gmail.com" <guroan@gmail.com>, Kernel Team
 <Kernel-team@fb.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Date: Tue, 19 Feb 2019 12:31:10 -0500
In-Reply-To: <20190219020448.GY31397@rh>
References: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
	 <20190219020448.GY31397@rh>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ZN1a6GHCKW49z7h4uIVW"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-ZN1a6GHCKW49z7h4uIVW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-02-19 at 13:04 +1100, Dave Chinner wrote:
> On Tue, Feb 19, 2019 at 12:31:45AM +0000, Roman Gushchin wrote:
> > Sorry, resending with the fixed to/cc list. Please, ignore the
> > first letter.
>=20
> Please resend again with linux-fsdevel on the cc list, because this
> isn't a MM topic given the regressions from the shrinker patches
> have all been on the filesystem side of the shrinkers....

It looks like there are two separate things going on here.

The first are an MM issues, one of potentially leaking memory
by not scanning slabs with few items on them, and having
such slabs stay around forever after the cgroup they were
created for has disappeared, and the other of various other
bugs with shrinker invocation behavior (like the nr_deferred
fixes you posted a patch for). I believe these are MM topics.


The second is the filesystem (and maybe other) shrinker
functions' behavior being somewhat fragile and depending
on closely on current MM behavior, potentially up to
and including MM bugs.

The lack of a contract between the MM and the shrinker
callbacks is a recurring issue, and something we may
want to discuss in a joint session.

Some reflections on the shrinker/MM interaction:
- Since all memory (in a zone) could potentially be in
  shrinker pools, shrinkers MUST eventually free some
  memory.
- Shrinkers should not block kswapd from making progress.
  If kswapd got stuck in NFS inode writeback, and ended up
  not being able to free clean pages to receive network
  packets, that might cause a deadlock.
- The MM should be able to deal with shrinkers doing
  nothing at this call, but having some work pending=20
  (eg. waiting on IO completion), without getting a false
  OOM kill. How can we do this best?
- Related to the above: stalling in the shrinker code is
  unpredictable, and can take an arbitrarily long amount
  of time. Is there a better way we can make reclaimers
  wait for in-flight work to be completed?

--=20
All Rights Reversed.

--=-ZN1a6GHCKW49z7h4uIVW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxsPV4ACgkQznnekoTE
3oOKuAgAiEP51kop8udkWuqVr6/o8OMvMRWwU4NG2GhUe3HfRiumDSZFRzdR+wjP
6vTWsK6QbQH5pCMAJy3SX+8pynS4BNO7Bl7LbJU9E1tSZ9HW///tCfSMA9JtmR64
ZKnc+ZpJRl5X047kFmbp7uBy+50Tt8bBIWhsK+fTRehMnSF2drdL7qI1HAh2CIb3
WWHm8VIemiH611kKXvjkedcPPDgCTuJCj8jrtfZswV6dpq9TS1gjW4syzzx5Bpts
7Z7Ou9PF9pGOu/fXQzvzE90dIK9nDdFZySQm4TP2kdfNz93Cx7ZV59+jKIYcZf31
OgbrldQQlbReupqCp+yljNyx0+OXXg==
=4KFD
-----END PGP SIGNATURE-----

--=-ZN1a6GHCKW49z7h4uIVW--

