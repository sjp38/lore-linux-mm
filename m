Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9A1BC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7238E2133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7238E2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E64176B0007; Thu, 11 Apr 2019 07:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E13906B0008; Thu, 11 Apr 2019 07:51:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D02AE6B000A; Thu, 11 Apr 2019 07:51:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF81A6B0007
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:51:52 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 18so5266362qtw.20
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:51:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=9li4JbAciQB6kgcEj0A6yp2jZtSSjmDuZnBSu5j3roI=;
        b=L6escfCQlW/AV62jKlvpTkyQTSpTm1q0rKfu3hqO0hUXT110+mNGMWbzRJD/PAd4h9
         eNz5xU74CgkM4LOd1kj361WiLthoKVnG60CxqrvV+ikxqEhPj8lbFuD8dxPcPSf56Lgj
         QYtodHX7sgmC3kJytYO6ylrhpOuoPkoF5+fvdYgVFxD3iKWxU1ii8wmnsjOQzmdO1KkI
         upfe8gEqSSKyX3Pq8B5VVtHHveOLZP4Fj8n5Rhl84vSSzwAWV/LtZ5w8qeujJ11XLs8c
         OdwDsiX1OpK+Oi9cyddKULm8Ugl2DxgMfei1qW++OpgU2XLYg1wTHGYlXIIERgSk6Zeu
         wocg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAU6/dwLo0uvBT3vsmcFWDGDVSSujywrFOGMPOo/T/SS7az40hph
	2SoPx8lYxxHaaP6XVQC8Rzm5tNeyqSq8umLEG30ArdB9/qrOoomR7tndelMpSG9y3Z1c7ZKoYkB
	c+vQYMcD4ne1QV4x+C2IVVpz0xqx7ov6rRirfSA1Qai4sluVjddltUVEytWmqVnEBdg==
X-Received: by 2002:ae9:e109:: with SMTP id g9mr36166517qkm.251.1554983512445;
        Thu, 11 Apr 2019 04:51:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzy0IzYLjfW7P/fOPJiGzuS1WULQ5+OAyp58IgYu8d3vay8XRuHhwXj5ir7Xv16VEndJZqq
X-Received: by 2002:ae9:e109:: with SMTP id g9mr36166472qkm.251.1554983511656;
        Thu, 11 Apr 2019 04:51:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554983511; cv=none;
        d=google.com; s=arc-20160816;
        b=JIYxLqyDxEi8BS44suWSPL8TTWFQMzyR/7fZFwu89ui01sdS2i0BfNfl2Y1h2sy9dU
         DiAup/gIgJ9Z1bYdyKM5REa4vxejm66S2oiMCij/Dp5b8rxMvbjrdngrQa/R9V2MRi1n
         0g5wiCJxqOCp6hvHf0nAOzhq86ubiiZdHala19mXOYwRjIx0C+0cM1x4yavRVoXUn6Zo
         FQaztHKm5AiKmi4Nb6kVvBczvSALBPiX2QEz63rqGpoKKxrDMNScSB3zOUuOUfLb3Y8Y
         Pi0+cPTyO0I/bO4Svb81Sfa2t2+IAf57GXVyCbV085CUvORKSymBBndqFQU+FC3/ndSk
         F4BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=9li4JbAciQB6kgcEj0A6yp2jZtSSjmDuZnBSu5j3roI=;
        b=D6V4Xwo/VJPRiO57hkXuo1zT4XjHedjjhUcEGEMJi6tDdMA43ItAEjLfXPAObBi5gy
         5LhJXD7Ujuse44NFuYxQkMpLDpjjrkBeW8AyGVTyL/CDKy7oVsmXUhzJ1VCbaCFvg+A6
         jRK+0d5tmplBM0K+QJQCD9cxdtJ6Tv6WNn0vbOpUVjQwc/B0No7A5E6yAbJSKFk0aSz8
         3KHJh84bxJDpPRVI2w0Lx+5gOUTg3wNrb5ZakzNy1GdEdjptw0k8VJyyGONWd+YbDkAV
         BAoVT2C2A/WAj7cnCVOVX/8xBgh1xTT36/lNuvzrt52zDqhWNQPxNZo+yF1RtPSSp433
         ZPGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id n4si10633690qkg.43.2019.04.11.04.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 04:51:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hEYEk-0000Q3-UT; Thu, 11 Apr 2019 07:51:22 -0400
Message-ID: <e1fc2c84f5ef2e1408f6fee7228a52a458990b31.camel@surriel.com>
Subject: Re: [Lsf-pc] [RFC 0/2] opportunistic memory reclaim of a killed
 process
From: Rik van Riel <riel@surriel.com>
To: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org
Cc: dancol@google.com, mhocko@suse.com, jannh@google.com,
 minchan@kernel.org,  penguin-kernel@I-love.SAKURA.ne.jp,
 kernel-team@android.com, rientjes@google.com, 
 linux-kernel@vger.kernel.org, willy@infradead.org, linux-mm@kvack.org, 
 hannes@cmpxchg.org, shakeelb@google.com, jrdr.linux@gmail.com, 
 yuzhoujian@didichuxing.com, joel@joelfernandes.org, timmurray@google.com, 
 lsf-pc@lists.linux-foundation.org, guro@fb.com, christian@brauner.io, 
 ebiederm@xmission.com
Date: Thu, 11 Apr 2019 07:51:21 -0400
In-Reply-To: <20190411014353.113252-1-surenb@google.com>
References: <20190411014353.113252-1-surenb@google.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-EhA/ljhQjzQ1y1msvysd"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-EhA/ljhQjzQ1y1msvysd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-04-10 at 18:43 -0700, Suren Baghdasaryan via Lsf-pc wrote:
> The time to kill a process and free its memory can be critical when
> the
> killing was done to prevent memory shortages affecting system
> responsiveness.

The OOM killer is fickle, and often takes a fairly
long time to trigger. Speeding up what happens after
that seems like the wrong thing to optimize.

Have you considered using something like oomd to
proactively kill tasks when memory gets low, so
you do not have to wait for an OOM kill?

--=20
All Rights Reversed.

--=-EhA/ljhQjzQ1y1msvysd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlyvKjkACgkQznnekoTE
3oPNQQgAs0Uab4UlWgiiD7o0gAjFu9zNhtef6Q+Tk1qFZDMnzCeQcQgFr9c4iRXN
YA7MqnAcKQ6mzle90nxueQHEgz067Eh9AEnnkzxnUEL7OmPsm7p/LKobNAelX86F
aJD2Ohpsaz4wDODe4je4iK2cK7pkQ5zkYn25+lm8MO5Ei4rDXLXTdTqwtHNompWG
V/64CxuTdeHiZa8HFrN2u+1SB0BUN2+kAJlfkkatfiDIUqyWNtN3oaQrK5/eFxXr
GnBrInkKVfr5+L2JfiCcC3fasbhQi4Z1g9HqQ7rxaT1QHziDMDhDp0g1ssR63nKr
JnFMfXOPt3pXbyfNAJB1ZOCk4xF1rA==
=JzJl
-----END PGP SIGNATURE-----

--=-EhA/ljhQjzQ1y1msvysd--

