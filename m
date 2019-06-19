Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E495C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 01:23:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E80A320B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 01:23:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E80A320B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71D0A6B0006; Tue, 18 Jun 2019 21:23:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CF468E0002; Tue, 18 Jun 2019 21:23:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60C008E0001; Tue, 18 Jun 2019 21:23:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 417796B0006
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 21:23:02 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t11so14260031qtc.9
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 18:23:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=finLkpKFnYwHV7QT+gJwmPAf4vzC8LEwarMs5T88Sgw=;
        b=bJOtxgI2Q2dptBaYiFW4mAIAKSfBrP+7WyeCXR21LWsXE0vCYdBU2AG3AXLnR/bm64
         0NVJzwcOoPNR1CuuVHuwyUXf99t4jh9+MPMfn75m3EsPrjiZYXCjpyvThA5IO6tjVlkb
         D82XKSBXzWLF9C++zKT9BKVV+RZowBGWyv7Arj3obw39j2ovxCmaOPlSnEoO86776BJ9
         u32DW71Jjgz+Zk+ZTtXwbwha3Kcp76aVPd84/wPALeL2TqTppboMf8T5MHOI3WZ6ncAk
         L4qhW0MXqhw4Bv8bak5e45nkmM3ziyiAG6fppHZYh9enYxpC/E0F6XvjXg60umNMGjlK
         G+fA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAVVkBCqsDEqQewxWT1t1UWCDrHenPgD2FfHyhxUGMa4BXkNihZv
	LGSbu9QHniFrl9ny8qdKfaopXUu1MREJhjD4EFAEnnDy/4VktqD/qM35WSGwvLWQ6StQfysMCy/
	zPw0Fw+CK/gkA06dV2MigZ1lQZ/StlD5hkdeHcEUiQLynLewFskm/pFDX6GlPecK2lw==
X-Received: by 2002:ac8:40cd:: with SMTP id f13mr91606847qtm.100.1560907382070;
        Tue, 18 Jun 2019 18:23:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/eTGBi4Of4CCVYpf60avkdU1MDeRd6UJQFaFRGQGJfjbD5aOLOC54+nt2IVXvsut9M2de
X-Received: by 2002:ac8:40cd:: with SMTP id f13mr91606816qtm.100.1560907381514;
        Tue, 18 Jun 2019 18:23:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560907381; cv=none;
        d=google.com; s=arc-20160816;
        b=jTWeXyXEPcfKL5YQN6MsvJgutXdAb4WD1DilRws4c8bwMPfBEGZdV1S23Js+OykzSo
         Qw9LpBf8rsv2xNUCvPvu6ct31SfkmdgzGPZT3rqG9XexBeYIJRo8VnXlaLKtnDv+cFWh
         eskOmYQbkqnQ7LCfu+O/82LqfYP/6qWc3KIS7gZv85wsApXvLpfe1G0efUr/G6H6agOP
         USAUUmQ9fHd6FRt3cZNbHDcwu8MMohunjOhTiwM9sUDyE94Ke2HbGh+Cd/fzfRI5UaGf
         n+l5xphDOdtpV8knBSvEBnMC4EEcfMbzbj4tSmzA4Tm5NIRNHtdlgV0dnxk6zKL4Hmnc
         1QTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=finLkpKFnYwHV7QT+gJwmPAf4vzC8LEwarMs5T88Sgw=;
        b=EnGxy2fp1ro+Om1rfxb9OJAjIA3dbGjiyJYTEkb6bKhPAqWA/P+xUR3rvzysZI32y9
         2a3EBBd7DquSCBadFIMOwhs3zg6Z2FumfvZZLsNpnTB2S0jdgi905S4325YRfuO5ybPG
         hFZly03K2FPg/beMTStLPcbdNyCeZWadLfhUX9A1tI12eiMQQ6mnWk8z3zS9U7iBkKFM
         7s7B/ATM0mD3wg7Rf9qhSXOgk9S3uM/dyKRPkcYWR0vqNBF0P4hWLqNbgcc4XMFGxNbx
         al5wyvIYfV0aYoqq+eO/V8yOtJhBhVjpD6KXaWChywy7otfNy4KMrBz5MIcar+SrjvOe
         8KZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id v41si1656018qta.348.2019.06.18.18.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 18:23:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hdPJR-00064w-2v; Tue, 18 Jun 2019 21:22:57 -0400
Message-ID: <e6fe65b301cba1db23d7fefb0031d8eb65574ee7.camel@surriel.com>
Subject: Re: [PATCH 1/1] fork,memcg: alloc_thread_stack_node needs to set
 tsk->stack
From: Rik van Riel <riel@surriel.com>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton
	 <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Michal Hocko
	 <mhocko@kernel.org>
Date: Tue, 18 Jun 2019 21:22:56 -0400
In-Reply-To: <20190619011450.28048-1-aarcange@redhat.com>
References: <20190619011450.28048-1-aarcange@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-j8zifAkn0SkfxwqrgUnv"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-j8zifAkn0SkfxwqrgUnv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-06-18 at 21:14 -0400, Andrea Arcangeli wrote:
> Commit 5eed6f1dff87bfb5e545935def3843edf42800f2 corrected two
> instances, but there was a third instance of this bug.
>=20
> Without setting tsk->stack, if memcg_charge_kernel_stack fails, it'll
> execute free_thread_stack() on a dangling pointer.
>=20
> Enterprise kernels are compiled with VMAP_STACK=3Dy so this isn't
> critical, but custom VMAP_STACK=3Dn builds should have some performance
> advantage, with the drawback of risking to fail fork because
> compaction didn't succeed. So as long as VMAP_STACK=3Dn is a supported
> option it's worth fixing it upstream.
>=20
> Fixes: 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-j8zifAkn0SkfxwqrgUnv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0JjnAACgkQznnekoTE
3oMOswf/djcJCMVBnU5Cmi4fAHNdioTMMgIwY0amYoEsKD9UK8CFtcWdcV4pZT0X
SlRYwbQeiyXRrwvT8bF9Pn/7veo3faq6L+UZVsGtavHY3dyUJSxfZN1RNn7KDUEA
YINnOjR0OpDznMwStaYWa+vaFHl8+spY01mn8hquLkd24TTzqjnc/xxr6NupYgSy
BJcQnoI+zcRSwRyyiBDHk1sC5iVwxqygLBr79lHyyFzS7vXXlJCUp/8ts6nYNesX
KdQ8JX8IMk8iJ640XcW5g1eZc4TP1jeDkSruB+2gXzgcjJrGLynxF8kO/j0Ji1fR
jZFvNRr+sZHJkFVIRYAiXmj4JP15IQ==
=7AjD
-----END PGP SIGNATURE-----

--=-j8zifAkn0SkfxwqrgUnv--

