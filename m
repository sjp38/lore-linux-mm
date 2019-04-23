Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F089C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:08:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0569C20811
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:08:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0569C20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A06716B0005; Tue, 23 Apr 2019 12:08:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98C596B0007; Tue, 23 Apr 2019 12:08:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82F9B6B0008; Tue, 23 Apr 2019 12:08:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59FA36B0005
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:08:47 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f20so12077381qtf.3
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:08:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=mMUc2jmRJ8oEt0uHFYqgENjBfiLvfMs2pEBixbnlGmo=;
        b=hW8D4VFEDjjoeleFhbsXuCHnxMK/22h2FxypAVokGRxk13hSP4e2exK59BlkQ8PhGd
         u8mqQzzcMnbm06CnlLwkVeoX8EV8AyI7/r2FA5Qlr5ciMiNcOxuCrhID7j7MyWmZqsGd
         DQGyxYO8fIlhZeJtMGs7UQX+LZhERb1J6kGGQPNOba2WNmXRWKpDsvOxQXF2shWal3NN
         JI3hnslNFXjbfpvGegcUlrWy3aZLIqerF+b7BLdiTCLUls2Q4hoFgHMT/psBoZeqeSRD
         3QT394fMdnrWUU6b10vC4ZrLIsR/X7L3Q8PQ/sYtX6aS2MH7lGw7tOxG6ygv6ACDE1IE
         moTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAUf7+UagW17W4Z04pU2wMlAgC9aXGyIdiHhM02ljuj6BLDsjVl/
	8SGdMeCQpcgmQI5nCO8Dq5CbMGNHrM+g223oS4XyLogkfWtkB7GK5SMn7EVNSZ/a/2aYb761DyN
	T6uHFIJXczlAKcSveXyX8MD9jsfmZn9iD6IJ3zd3x8VFDiKoDGFvLlIomeVQUzOjeOA==
X-Received: by 2002:aed:3fc1:: with SMTP id w1mr21556841qth.2.1556035726963;
        Tue, 23 Apr 2019 09:08:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJMghNjKkH7YiG0w9AjQnCPt6H7V3EC2fBx/hBBmDFrwKz2MMPuZm4p51k2YPGg8EGyUAw
X-Received: by 2002:aed:3fc1:: with SMTP id w1mr21556762qth.2.1556035725965;
        Tue, 23 Apr 2019 09:08:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556035725; cv=none;
        d=google.com; s=arc-20160816;
        b=lw0gwd3lLEwTHYFa4rAOi7dqno2i2KZPJYBSjtO/3clxOq6p9jzn8bOY5lLvL4CBnv
         tqxJ91T1DZBGSuhBU0Qa/stYHyUlw6d3xUwCB/vfu9uzs9mUXeMwWgfvINfZBONglv8S
         XzHEKXytVkouJkUWkt3PN75pCDC60LtVr7MhJefFbSVzW5gA67vJDA6XCcWtgOHmhV14
         ryqv3vQXLYBjYLEiQ8zvM5EggmotaHHw0tVeh/T6JwdaYFtQuvoANBiU/tP0wKgc88oS
         2xyhEHaEl3vzcXG3/PWqTmEZEtOgdqxeMDo+VYZ+TFJFISleEvFSJmuBwvY0e4l4zb4B
         tDJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=mMUc2jmRJ8oEt0uHFYqgENjBfiLvfMs2pEBixbnlGmo=;
        b=xeOOG5Cb1f8eyopyukJVX3zxcoNACRAcpzXU09MlEDCDK/V6XzBUK28IZpS5PLaq8P
         YfiojPTfbGQIsWK4br1qk88SauqQPgDhNvzkhb9FpwxFWuTEvaw74a5iuG85/mwbE4Gi
         0FPPu18veriEoaEpY/1jUb42mC0qbbryenTv9RH+JgKwlKQZd1RaSnCFFEf5N6WGLNl6
         2yXr8mgIh8RiiRreoan1QlSb2wNdgMapZWmpuzITyGq7Q3N2KvMKr+Agh5JoKR3yrnry
         RVkPTUnSo8/AObKKmJWrCeQUQb2IWAwTOBzqS7ZJaN25uHf2f3wved+vsdS93zEWFema
         /2Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id a19si1077037qkg.239.2019.04.23.09.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:08:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hIxyL-0007iT-M3; Tue, 23 Apr 2019 12:08:41 -0400
Message-ID: <8588314f167c9525e134ade91afdbebcd9e62eb1.camel@surriel.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
From: Rik van Riel <riel@surriel.com>
To: Shakeel Butt <shakeelb@google.com>, lsf-pc@lists.linux-foundation.org
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>
Date: Tue, 23 Apr 2019 12:08:41 -0400
In-Reply-To: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
References: 
	<CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-6RxJqoLWRhnKRlHnRpNy"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-6RxJqoLWRhnKRlHnRpNy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-04-23 at 08:30 -0700, Shakeel Butt wrote:

> Topic: Proactive Memory Reclaim
>=20
> Motivation/Problem: Memory overcommit is most commonly used technique
> to reduce the cost of memory by large infrastructure owners. However
> memory overcommit can adversely impact the performance of latency
> sensitive applications by triggering direct memory reclaim. Direct
> reclaim is unpredictable and disastrous for latency sensitive
> applications.

This sounds similar to a project Johannes has
been working on, except he is not tracking which
memory is idle at all, but only the pressure on
each cgroup, through the PSI interface:

https://facebookmicrosites.github.io/psi/docs/overview

Discussing the pros and cons, and experiences with
both approaches seems like a useful topic. I'll add
it to the agenda.

--=20
All Rights Reversed.

--=-6RxJqoLWRhnKRlHnRpNy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAly/OIkACgkQznnekoTE
3oO6ggf/U2X7Nq219+xAJ96NX5fbZ0bHXaksyWxg3nAth8ai5BKGJQLBog7GGnVd
g/+B/PaIkhx5l3qijzxwNJ/aTDuoKp+C0yAd5+5W6ecL4PX0z/7V2KjYCPVWehql
PYNelh2MC0+MaFuLHOQ+43ITlBQbiNJTWEGpgDfwsQcnTYM2gZL3wmLNwMvP6ugW
GaqqqtpzmJ7zZcokB8I+95pelQA2I6GpKtMPMOPJo/kLslvUtwaT0B3GE+Z9RF/G
aXIjNRzy3QQ67bmcrfNUx7qDzZHSuRo2+Nk3bmWWO+HjJRtr4ERGdIIBqZNESbUF
at1+YjW+BipD3Kt+ATsSi3xHIR6GzA==
=8Rxw
-----END PGP SIGNATURE-----

--=-6RxJqoLWRhnKRlHnRpNy--

