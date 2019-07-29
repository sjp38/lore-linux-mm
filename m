Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7BB9C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:29:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77BD6206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:29:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77BD6206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282C38E0006; Mon, 29 Jul 2019 11:29:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 233088E0002; Mon, 29 Jul 2019 11:29:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 122978E0006; Mon, 29 Jul 2019 11:29:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id E50ED8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:29:42 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id p193so26632500vkd.7
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:29:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=BTJIB84X56fbn9vPQJvEuMp4JcmuXiNPP466uIiJgRY=;
        b=HkLflCoS5cuyZWS99vP5Irg10WFbHB6EqZkg0tzFyfDO0sZ6OvLVcfZuJIhIdySTeG
         /cg/4EL+0Q+I4vtJu4RoaIU3EUcN0s5NHPML0gHeNLnna1rW3I3v6eKjmt4mKy6T5CHQ
         ot+gx6/VPYl4GcdmsYPU3BiXp29sx1TTBSfvr1fZSQqx5tmXLHgOhCD87RXE4/HJIWY+
         spG+E2vhCqhpzamq4evvPzULLqaTaMVNa4DwM0BnF0hxC1TgtcsF3YsAXzEhVn+n6crx
         qtFcks+vFyefriGuMFjKYJpHtksOJTaffMJT3/oheQ9rQDEv/68tfL217ymV4Ruu0sng
         Ifng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAW0pBF1TSxEGItC+H6uOwQNUIXXVo+JkQim+iGasb6hG+UaEpDm
	/aDx8hv2ipeMedvtl5cDwEnnxRcEuERtNjP9hblaUSeh6ULxiZBp0DNfXB4pD1ho1pKfT+OA2Dv
	6kaMwdZoCEzKO8SlYUqYEht7xXBXjFoCrCTCdcig7P17STbjjjuEmJiaPBd0tA9wfmw==
X-Received: by 2002:a1f:20f:: with SMTP id 15mr40688302vkc.15.1564414182681;
        Mon, 29 Jul 2019 08:29:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQyukEIbAx8tRcRXRwMgUeNxNx6EtYAZyUelRD7+4+kFDukV94qK8CxtSJG8K0cimy6SL2
X-Received: by 2002:a1f:20f:: with SMTP id 15mr40688246vkc.15.1564414182142;
        Mon, 29 Jul 2019 08:29:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564414182; cv=none;
        d=google.com; s=arc-20160816;
        b=UAIcXims1XnXaPCuXqodoBiWTQxxyRaV5+1V3iC7uwRIc8JZRM8oXAMx0Iq90j+AvA
         5PAXvzUZpe8DszXjHxRNAPcH0wcwEktHARbb2uynRt+7rwOEPASIG+63MLYbnsf0d5f5
         e0HTHChKzhzlYOF0pA11hynrUKiJgi7XOZ0TtqlpkpOjiXVPZuvXrdvW9o30FtGIoiy5
         X18uA9DTeRfXCWusV1Em25pMW7um3kg5pEXrRYBlmhcRreFmrP0BBrXY6oNrBQPvloX1
         X4LfQpVVecnKZb3cYAGBxPIZUGmlCS7bVKgYq1Ktw7fs6GU3ej4O4PgxAgco+l2LCw+9
         7acw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=BTJIB84X56fbn9vPQJvEuMp4JcmuXiNPP466uIiJgRY=;
        b=Qi0cC+fB/DCGM/5Dwz3SowPEhLpgt8QrHtYwU2LScqQJNQMTyhgzmSmFGH9DTD6rw1
         QGnJQzFSaS1aYUCchbj4Zz5ICGRbJexpXGAYLHkeYryTIuVsWs85xa+pJTRrHQNX373G
         /ObHmQLRu87TzvVnWQGZBCd03FoZO0mW0YuMsOhhJj7LKkYe3mpZtatpxvWx8M3NeXE/
         t6Sr6QuGiMvhZ2pOmBh6i4f4Bfg9/Ne391+P/MhlaKBpy47v0C8RwYTaTnGV0SXlcyj7
         egO4lC1j8HIz/Emjg4QmK9lbj6t58INTPgpDCnEGk+2MHKF8QVr1nK9RUJ7mhncahWXD
         ihSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id q126si14271124vka.2.2019.07.29.08.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 08:29:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hs7an-0005ym-DC; Mon, 29 Jul 2019 11:29:41 -0400
Message-ID: <5335b83c3371242f75abb6c92b40c665bb8f9ce3.camel@surriel.com>
Subject: Re: [PATCH] sched: Clean up active_mm reference counting
From: Rik van Riel <riel@surriel.com>
To: Peter Zijlstra <peterz@infradead.org>, Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Phil Auld
	 <pauld@redhat.com>, luto@kernel.org, mathieu.desnoyers@efficios.com
Date: Mon, 29 Jul 2019 11:29:41 -0400
In-Reply-To: <20190729142450.GE31425@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
	 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
	 <20190729142450.GE31425@hirez.programming.kicks-ass.net>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-xhoRZta1p4CDAjhhG3pf"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-xhoRZta1p4CDAjhhG3pf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-07-29 at 16:24 +0200, Peter Zijlstra wrote:

> Subject: sched: Clean up active_mm reference counting
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Mon Jul 29 16:05:15 CEST 2019
>=20
> The current active_mm reference counting is confusing and sub-
> optimal.
>=20
> Rewrite the code to explicitly consider the 4 separate cases:
>=20

Reviewed-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-xhoRZta1p4CDAjhhG3pf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0/EOUACgkQznnekoTE
3oOjJwf/ajhjMXP9koUzmYeZd95QTTdo4qKU1rTnCPbOw2EJeuQ1PO+XoaWfG9jI
xK4Mf1ns4ypSWTut3wV3PCsi/RjWQNnbSBsEwPPVrmhivjFwWSY8GfQ6cDNnNASA
UGOd7rBvuGaDp6oJCfLHQz9lRLaJI47EHZuK28IvnWbjMY7aQyRMBnV58y0hAhoQ
HjAoSz2I4M/w37q94IVKYPKGuU+I+/g5zK6ZaY4PrBkw7hatv/yoUt6y3KoglFZY
APK3yTvtCwQQFNYdLMAXyJswmHeiLgOn/5c99NZjxU2nPv/OQ2kuO+NaXo0Cq4ac
izDJuwuoYNuCP/XfZNMLVQz5Inafxw==
=jzZW
-----END PGP SIGNATURE-----

--=-xhoRZta1p4CDAjhhG3pf--

