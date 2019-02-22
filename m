Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26A51C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:56:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E256C2075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:56:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E256C2075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 826408E012D; Fri, 22 Feb 2019 13:56:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D52A8E0123; Fri, 22 Feb 2019 13:56:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EC208E012D; Fri, 22 Feb 2019 13:56:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 462598E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:56:21 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id y6so2280818qke.1
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:56:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=2CYdQPsOMc1PG7mbT5ICeMhdtQOIdRtv1XXJNQE7gFg=;
        b=O3wqiAr+R/bFjQfcCr2hTuPwHP7GkjE5N4FIMAu7Pur4SiFM45yMV3ZmB1SCS2iXEf
         vduOLEbD/Ph2ACc7KK5tPpC7QgdYZnNNBy3cPLQONVT6mQK8Ee7+SLpLMVY6qb+LnxSf
         9Lh/tvbO4gj+1XiF9uShADfnhUA5D2TB+y2Vhe+K9Ud8t2kr/3m0jTSPaEaU14gAP7/l
         zIMP7P6dPyx0YyinndvYJCapLHGpM9RszPcqpWf9UYeozLmSCvLrISYywqMIp5JxRq+1
         jRsNWqXflruRqONvGecG1NyE7fCZafkzvoDn3ZjcjgvJtTNaTFFo6OviaCtKbLd7d9eX
         mZ+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAuakf9cyZ03sGHl+iJVlItW4MhrfjMCI59KpIkwMfpayWJabkqwy
	STLH0TKkJEbx0DVZXmDd2el7bhxlUSzkNsS1j58fD9nfsKLU/FCleAbCY9pX+ixDVzvhm0RHJpR
	YJ7PyTX5+jZBl/R41kaeZMcM+DEKZp3VOCOkKeJVHXF1Comi92OYMx1vBebY5bbkXxQ==
X-Received: by 2002:ac8:266d:: with SMTP id v42mr4238490qtv.116.1550861781004;
        Fri, 22 Feb 2019 10:56:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaWd0OkmKMcbKPgPjwmjKDA6K5d43ZCxsi9GpgOWFKP5JRJmpok8mhty1+I3tPBobUKQakZ
X-Received: by 2002:ac8:266d:: with SMTP id v42mr4238425qtv.116.1550861780086;
        Fri, 22 Feb 2019 10:56:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550861780; cv=none;
        d=google.com; s=arc-20160816;
        b=rSpL3vf7jah1q+xOiz0v8jRtRv+2YO4i+ddwLsr95FocYuktgRJI3DWiKKUVeqTRXv
         tHpU0yNcglDsb+Bm95s0Iwa2mTynPUWJbnakgRGD7BmV72Ed3MZbqPEyDOf5sRBEHUvP
         UbBQCcNFjRBv/1hI62aR2UDaxhZWgpTek7E35KoyNZf8B7Z8af13Zcu11+bfOIAtxgaa
         WYG8SL72+uKxdyK79cMWkAQ3+qGSVvDS7xGtGN2GITDyAYrX0gTsYW/vvLyHpwtpSEfU
         AijzFDpxZuTJG+T4zRLPGUi2gXqKDmwhRhNSLwESwYgY4JoL3SeNZXHxldIaKP6oeHli
         fSoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=2CYdQPsOMc1PG7mbT5ICeMhdtQOIdRtv1XXJNQE7gFg=;
        b=uWI119t0BkygrT2cRw0gVlU6hR0pUVwORaEdj1bGT+I3fD9Sbsuohri2QkF0MR71Au
         LIBAFqCfqWzh0kyF9evt3XLy1C8pj1ffqAHFMG2bwSgrrnMtryCkm5XzpRwSBTCSTOJj
         qRljvkY1we42M+7KZnsmR73k2HH4Oq938WCik85aVZeIL73/YqZb9ySGtV7oXLkyK3xZ
         MkFD9JIkHa6HaEUcBnh4r4wd4uWXYpmGmXchdzSW1jG26QZZx+ZoKik+kS2EzX+xohRL
         c3nnT1h/IpDyEOJ2ePzYOxJIFGWL22yAnd2QNI7aVM6S10x3SQyvDcO8TglXx7Zh5eH1
         cAbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id c2si1465211qtd.26.2019.02.22.10.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 10:56:18 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gxFzZ-0005ky-Qo; Fri, 22 Feb 2019 13:56:13 -0500
Message-ID: <f39cf989bc4c39c6065cd0896c99e20c63316b3b.camel@surriel.com>
Subject: Re: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
From: Rik van Riel <riel@surriel.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton
	 <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner
	 <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka
	 <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Roman Gushchin
	 <guro@fb.com>, Shakeel Butt <shakeelb@google.com>
Date: Fri, 22 Feb 2019 13:56:13 -0500
In-Reply-To: <20190222175825.18657-1-aryabinin@virtuozzo.com>
References: <20190222175825.18657-1-aryabinin@virtuozzo.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-zrqnWZMPMJ+zyetOZuRD"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-zrqnWZMPMJ+zyetOZuRD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2019-02-22 at 20:58 +0300, Andrey Ryabinin wrote:
> In a presence of more than 1 memory cgroup in the system our reclaim
> logic is just suck. When we hit memory limit (global or a limit on
> cgroup with subgroups) we reclaim some memory from all cgroups.
> This is sucks because, the cgroup that allocates more often always
> wins.
> E.g. job that allocates a lot of clean rarely used page cache will
> push
> out of memory other jobs with active relatively small all in memory
> working set.
>=20
> To prevent such situations we have memcg controls like low/max, etc
> which
> are supposed to protect jobs or limit them so they to not hurt
> others.
> But memory cgroups are very hard to configure right because it
> requires
> precise knowledge of the workload which may vary during the
> execution.
> E.g. setting memory limit means that job won't be able to use all
> memory
> in the system for page cache even if the rest the system is idle.
> Basically our current scheme requires to configure every single
> cgroup
> in the system.
>=20
> I think we can do better. The idea proposed by this patch is to
> reclaim
> only inactive pages and only from cgroups that have big
> (!inactive_is_low()) inactive list. And go back to shrinking active
> lists
> only if all inactive lists are low.

Your general idea seems like a good one, but
the logic in the code seems a little convoluted
to me.

I wonder if we can simplify things a little, by
checking (when we enter page reclaim) whether
the pgdat has enough inactive pages based on
the node_page_state statistics, and basing our
decision whether or not to scan the active lists
off that.

As it stands, your patch seems like the kind of
code that makes perfect sense today, but which
will confuse people who look at the code two
years from now.

If the code could be made a little more explicit,
great. If there are good reasons to do things in
the fallback way your current patch does it, the
code could use some good comments explaining why :)

--=20
All Rights Reversed.

--=-zrqnWZMPMJ+zyetOZuRD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxwRc0ACgkQznnekoTE
3oOzJgf+IxsPL5yIB5u027UvllE62JRrGLEE5jT6pUWMuilQAYqXRs4OJ+dUXeJG
ZFT/XqnrA8OQ+HtA9yZ7qvu8O4QxQvrHA2DD3Xvc62SyuMQn+07JT6oreNsXSAJR
j4M3bvj8SGycS81sImxx7q5TYB+QSpBsYOzHYultqY4gO6xiAiCU4+FNuO9V1OoI
jVLuIp0aMmbMhE9lEWzMLPfPBMH3uZFELmPXTJDlE6G8Cd1CTAzFj41Po99yYN0w
BtdHFWSU2cmSg/aKVJCGgVoC93EiL6m7DcuYJWQtgWVJ+tVxVwPIZ/ICHRbC0deo
19rUK2TX7FzIBhReWch3aVNGDnokBg==
=VKDb
-----END PGP SIGNATURE-----

--=-zrqnWZMPMJ+zyetOZuRD--

