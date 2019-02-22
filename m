Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02825C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:02:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B864A2077B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:02:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B864A2077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D8388E0131; Fri, 22 Feb 2019 14:02:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 588EF8E0123; Fri, 22 Feb 2019 14:02:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49FC98E0131; Fri, 22 Feb 2019 14:02:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1EED98E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:02:03 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d49so2922674qtd.15
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:02:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=HSo3UdpSnfoAVZZuWug+WgcMHS0Y9bFYfKiKNJXQ95I=;
        b=SinWw5cSae9LtbXcFVojHS1DErYEiV0MXU1mYZhxGr9LVPhGDcdLOmtpIQoN4VN2dv
         ojZw3ReprbEEbnJykvwCf9ouxOoTRc3qofvKmY05hrIxsMO2e2w29lACy8aSZiKOJm2H
         FBNCNbFI8GAo1X1jyUCFWdFw1/i4/gGeAoKsL4eimRQAIHszio2k8+BP7eXepTMkRub/
         Uh8oSLZR1UR0CDC0vHXT3jSGjiJTwGpgBVfvA0KrfXFZFg+ItZJC2qH5PsPwq6r5aPe+
         LpPrfVOpNR50LmH/ji1s9JQ9Qhf2MULv5ZgOw9VF1BFd6HT5DZHc2X524ZtuQPaBXz+F
         lVGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAuZfUQNWSmZbhCbwGQwHZQgpYjebHb8+54EzjKJMvCpGqAofYEN8
	6xrEH6+OHaVXO/9NElr6sGFzxRXy/vOd7zcfIz0kKnW7KWIeevHQU+MDqX05p1y1uxY0ei4/6k3
	aFEPqHZeoqa50oAhE/ueseg9FlVmkv3BcMYtp+BtEsyLUXqH0/8/hLu5VOZ+r+u1svQ==
X-Received: by 2002:aed:3f82:: with SMTP id s2mr4426040qth.284.1550862122873;
        Fri, 22 Feb 2019 11:02:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZI3/5hT1LEdRaY/kDKCJoppRTuYLmi+RPY8XKlbNrX9gT42AARuEakh9AT3o9u0sI7Cpqq
X-Received: by 2002:aed:3f82:: with SMTP id s2mr4426007qth.284.1550862122270;
        Fri, 22 Feb 2019 11:02:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550862122; cv=none;
        d=google.com; s=arc-20160816;
        b=wE68q+1OBgZ4qyF62cGOYYwCjzRKR8JZ/DoOsXYd5yZMIOBK26PdarsId12LC4Wz2A
         /r7Q0AvEMM6c5ebZQ6sWhEfLvxzXKKCjunA7VlKFXEQyZTSYRCEndGxEd+srGCXGACoF
         hWbkk1Scg8lJjCSz7PO5NvOHAJHNIVFS06ujiuk+Fymz3gnwShLGGjikTXhZ19kyfF8o
         J5dJ43ztWT06SjnwSegQlPhl8J0zKuEdVhicYThNQJEIG7v1sV2QtFfKKi9rOixB/5MT
         g5zuWyqtprH081G0xqKGQfEeC/a2omjntAI9gf300Mo+r4NwpbHDCQl/7H2pTMs7Jqih
         3MVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=HSo3UdpSnfoAVZZuWug+WgcMHS0Y9bFYfKiKNJXQ95I=;
        b=w1vL+9tZNM1k4z6S6zU3NVT8Gm6nKRfaM3xjVjdtbFEp9UrF2T5X7Ew+IU6N/0c2xw
         cTCmMcZVps5M6rDnCurTOhVG+Zyua5MJeAW2Dz/8MwA7X6ZhYrm9lEkmJS594y0YspJm
         iNAA+oHRymco6DexW52s54PxI3tLK2ZJkJLUgM+H9r/zEvVvUb5oKRiyn77dSpM1/hbL
         4JoKNnOe4gCYxazMB2kaCdqqEr51H3JbbeIiPlc7tiTK0OBuxy9MjW56mTGrKLMQM6na
         3HsG9EdKYsJoEcyOrnIGe0qSItvH0PLA+fMsukjxj13S9ozkd5XP274p9Ky10EkLH5Zo
         dLog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id z54si750227qth.393.2019.02.22.11.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 11:02:02 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gxG5B-0005nh-IE; Fri, 22 Feb 2019 14:02:01 -0500
Message-ID: <855102f6f7735ea71964fb14db00cf9552530cbf.camel@surriel.com>
Subject: Re: [PATCH 1/5] mm/workingset: remove unused @mapping argument in
 workingset_eviction()
From: Rik van Riel <riel@surriel.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton
	 <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner
	 <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka
	 <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>
Date: Fri, 22 Feb 2019 14:02:01 -0500
In-Reply-To: <20190222174337.26390-1-aryabinin@virtuozzo.com>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-GYX4p7ewd54zuNzzNR82"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-GYX4p7ewd54zuNzzNR82
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2019-02-22 at 20:43 +0300, Andrey Ryabinin wrote:
> workingset_eviction() doesn't use and never did use the @mapping
> argument.
> Remove it.
>=20
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-GYX4p7ewd54zuNzzNR82
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxwRykACgkQznnekoTE
3oPODggAjpaOQ1aAPR8IS2tINpinSdPLB7xQ4tCR2+VEBqToEdIz6fcuRFb3cAJL
ZIflsoTCDvpQqFzkv1pUsf5fQsuMLbTiEgc/KvxH6s7ysIx6sbeXrfQIYalYHwGT
yU4TzK7FKJjGHX6LEjDoUSVKNzklPQWLFzqRuWvMj1P64DWyQhDAZUo0a6mJ2cEc
T2TchsJvN0X62vJCgWTcZ+sbOqCopA4LRdOzcc0TVfba3h5nN292PLMVgneq8stn
P9xi8Kwg2VtBqLOv1S4gy4Py1X8r5dXlk1YpCw1Iy+013XFgGBwhE5YKUOJDdUnR
9gIvwU3gyoJUvRszdPsYeyGzMuQqOw==
=cbTd
-----END PGP SIGNATURE-----

--=-GYX4p7ewd54zuNzzNR82--

