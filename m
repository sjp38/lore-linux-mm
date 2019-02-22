Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABA26C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:01:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70E6120657
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:01:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70E6120657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2302C8E0130; Fri, 22 Feb 2019 14:01:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 207C88E0123; Fri, 22 Feb 2019 14:01:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F9598E0130; Fri, 22 Feb 2019 14:01:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7AEB8E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:01:36 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s65so2243172qke.16
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:01:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=aPTtQQsGbJy3+tqX8vU4luda52cekNnID2Uj0h3Qx7Y=;
        b=l01IioUklRanvgv1+QDQP4Ntsc6X63E1/8dWY+4XQXM6byoCyGC0R07jVGqQ0545B9
         5R7EALUq3jU3a2nxlQuVmyosn/PVU3wR9W0RQ+BNcS1R0RKh4ogMLu5awBaid3tpiP5l
         EcJX6Hqc/OsfjNSEzEMdMX6JtLSWeOuIKr5x5uXvSNDxgC8nN8Cv1LvCc+BjvGp/qzjp
         g3BTBLgIfxfDkKy8hHo3+80/RIfcyepxDB21t9L3UJWp94W++5kmTVu29KOD5kvK3TNc
         YrIF8GZHCB5tFjaU8CvmHcFHlGadEZUXB87V/paUyDIcOVl80J5ud38p+j0tXVVB6F6E
         Fgtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAubdoFKcmO7tbbqgl40kExkQdmEdj9BcLfFEJFeXstH5E6hM/KLy
	BUKbapxuiqax2Vu/bWaChQmrbr34SPKGLE8jNIPiZX9HzdbPn+jsJzaUeSJEYP11PfcOZ+vraqS
	cMmwuCasySJU5gZkqT/eMPv5kb07zPcPEBOsB/xwSFQbzvYs+urqBIBQ9bgL7NANH4g==
X-Received: by 2002:ac8:33f1:: with SMTP id d46mr4223092qtb.319.1550862096673;
        Fri, 22 Feb 2019 11:01:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iby5DMR1FGI4ewXGLXKVLNIV08GvZ2UxNqbQDk/LSkcidRh+MQlQruSd0eq3lUcrR1asz2o
X-Received: by 2002:ac8:33f1:: with SMTP id d46mr4222926qtb.319.1550862093999;
        Fri, 22 Feb 2019 11:01:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550862093; cv=none;
        d=google.com; s=arc-20160816;
        b=M9t3YRtdlKwPF79d6TXU18U5WEAmRDJ2lUlIrB6KXFHrh1u5PeMdkhYiTpPQHUtMgr
         4Im+7Kac/yHH/7tHYygGF+6gB9TmJWGr0llB0FAQ7zwOvDMu/nlT3Gx5+9JwTrZHUZnl
         5fhmN6h1gv4d7XLaHWmlPvgkL1Kv86gBe/rnD5nUB3Szq284d/QQPmp7bYmu0qNA9CMA
         ubQdY8rO84S4CklLvIl9wSmyWIE0e1nY2204ZDF8Cnskd1GKBVU+errWQU4ybxQr6KLj
         It44rcAH2ruiU+sp3hSc7nHbX7SK0j68uSGyHvYJUnjIrDzkzKYLXC8h6KMlJkWYKgE/
         CajQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=aPTtQQsGbJy3+tqX8vU4luda52cekNnID2Uj0h3Qx7Y=;
        b=eHzo4/ypyYIXgdCxtth4+7mTTECGw8Df1rAO0CrffsNuwi2qABrzn/Kx7OA3LZTtYg
         ZNGKTu1Vlgs81mKlxAjlXyOSKM24OmpwS9iVm2S35YtpNrVDlEYG9ZJRfE/+1rCtLv34
         +LlEoU1iQnpNeUMUBZk5bH8j7H2aowhTANUCTpI+DYGie/decwTD47wFb9jrlYpOcvYY
         mQzISnvgGAOo1QGQiii8x8gaQ6Buy0IEeVm1WtOvfDgcAQEQnYImcQUkVuB+logehZsz
         GPdJLlPOAlPlWyv5iWNMT6G+g1r6wDq8bTlLQxwpMTz9k4dnb1UNNyYR20qP3HKy1JVo
         4Z+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id w71si914347qkw.19.2019.02.22.11.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 11:01:33 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gxG4h-0005nI-SZ; Fri, 22 Feb 2019 14:01:31 -0500
Message-ID: <0cf441e7cb7cb4cd0ff2b455928497c9a1fecfbf.camel@surriel.com>
Subject: Re: [PATCH 3/5] mm/compaction: pass pgdat to too_many_isolated()
 instead of zone
From: Rik van Riel <riel@surriel.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton
	 <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner
	 <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka
	 <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>
Date: Fri, 22 Feb 2019 14:01:31 -0500
In-Reply-To: <20190222174337.26390-3-aryabinin@virtuozzo.com>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
	 <20190222174337.26390-3-aryabinin@virtuozzo.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-b1FglSvBXlFgFSAciTne"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-b1FglSvBXlFgFSAciTne
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2019-02-22 at 20:43 +0300, Andrey Ryabinin wrote:
> too_many_isolated() in mm/compaction.c looks only at node state,
> so it makes more sense to change argument to pgdat instead of zone.
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

--=-b1FglSvBXlFgFSAciTne
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxwRwsACgkQznnekoTE
3oO+dwf+OtiXa8Llp5bfJjVguOx9HYLmnPFltiIVv3cApI8JcvWkY/iLuYytUqy5
LsjLY4zuKS6brYtDnlVtcn0sfprziCQqmXxnoI3G5PjGy+s1XVPSgMXVC0LAkqiY
un++1kK23CMAL825PXcNp5B9/dK/x83j152d6SfDfyCcFiz2jv3fA+zRL+IuoKa/
RL5F5EIL4juD8jU5AbfJbryuneQlRDHAx0FgHt/Wz/MNEJfPYGAo2KLkX1i7tw4k
Vz12WDXKfyRsHIpC+U+zHukg4lUAjhSYc2z2bGOQTpxX4A4BBYJWXy72hrngqPhc
UeVV5nBmae+0w+L+uRC9Om/NU645ZA==
=H6nL
-----END PGP SIGNATURE-----

--=-b1FglSvBXlFgFSAciTne--

