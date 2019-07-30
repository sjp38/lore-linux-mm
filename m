Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D1A7C76186
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 00:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0085E208E3
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 00:26:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0085E208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D0768E0003; Mon, 29 Jul 2019 20:26:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 580E18E0002; Mon, 29 Jul 2019 20:26:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46F398E0003; Mon, 29 Jul 2019 20:26:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25D488E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 20:26:52 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q26so56885316qtr.3
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 17:26:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=OG43dKE5EHdLsloVp5kr47KFclKp0v6i6aNn4A4Rt1Y=;
        b=AnoBP/iNz/5b3F4c9eCresxIeUw2d4pZrxQVwW07ssOt2eqsQROz+J7uUmw48wKrKj
         OruiZ03fXhFGxWA2o8qV85pGvfwHnW5wiYZ+vhElg2LRYyoGGfAxqGykGvnkGTA1yHqR
         AhVdcJUI572ZN58pyE6DfK+9mgmiKeeg0CG4Qx0OS5Tf/frCqm77z72ErvaOnw+Xj3dI
         CMPiiW4nz7vg9l8i6NR/tBHFQlpBS+p1+hi+Nll2U1jb4SvmZPmmKouylrJLGwYp9Wcf
         0Ah/h4icHn4h3UeyM9LzEaNDIDiy07aub0+mayDXSlhZhaAqA7KW7H09bGTPyWyEMmeC
         FBQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAW7fpyu9xoLlfEbVr5KrbFFJ+C9RZ3Zur/3654qP2i1GYxCgUZO
	xLxq+BOC2o1RsaAXeRe8eVU2JHegsrcCoISKYlPgJea7VD+req5ADQQRxxJOiuiEgmA765eaP5f
	P3egh9wFcIhgWs9+LpYmWMYipzjecj7wVIv48Plkc/qEz1kAaThvdHEVCSSG2xOrR5Q==
X-Received: by 2002:ae9:de05:: with SMTP id s5mr76983634qkf.184.1564446411861;
        Mon, 29 Jul 2019 17:26:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQ81TfuEpUrWpmZ9GaUW5zX5qj5cpQAEnLTNOpXx4U3oAoSL8pjx9w6wB/4uZBNrXUXIrX
X-Received: by 2002:ae9:de05:: with SMTP id s5mr76983596qkf.184.1564446411178;
        Mon, 29 Jul 2019 17:26:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564446411; cv=none;
        d=google.com; s=arc-20160816;
        b=hOA0evbUkSX0HAf0sSn71f7mZXRT5puA59i2z7IRt23/X6zqPHRDkwmyLkerHAULiG
         Ulha42csYhfzxsb4SIKJdVoxRhnircNka2+Asn6x4jh1OFuPXPbvcktVsjzajaatB9TY
         O9QMimN3Mrp/LnTvb6wDCdOchVJeNMqdMLG3uh6L3iPj0bORsyI0ywNqN/x9ksVGHxmk
         y0M8Hw3WxvR/xCKNsWKPAgBxWXi8mUZJC6FfYL6CLjW1YPZv6ngujIhjRG0BslPlePyq
         D9Br8Jhq33cqRKS1rT6IkXOxnmTrKcde7qzNEfK21YDgzacoEwkYjbZ+jCIz371NDyWq
         pW3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=OG43dKE5EHdLsloVp5kr47KFclKp0v6i6aNn4A4Rt1Y=;
        b=fQrGy3J0csJbqhQYoPZOXTVJqwL8+itGdlF0w/0zNEiV/VqdFjMSfx2F1IhZ5INEXP
         45F7wYrJ583V+TXj8ZV7XsusYSP5sIw65ciUpHFnWMw6h2iQZ7acPn9hPwS0+R+GsdUS
         Svf8rZw9Tihm4pJgxpqtVUE6BzD/Otd9TggAHHE6r83K4oqD+4K8g/dR5oTUvCTCTK4R
         TLeKdvLkAzQrfN0OHQHTSLwoGIacp/hTZPm1J6nmBGTLfLOqzgRECUeLR/BJnuyEVW21
         6Hm1euX576MeW+jDth8iLP7lGVtMHup0ZWtq/JaNN4We/S55M3bV5kBdsVdJnV0ELSr/
         inbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id p125si33928949qkc.197.2019.07.29.17.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 17:26:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hsFyU-0000oP-0f; Mon, 29 Jul 2019 20:26:42 -0400
Message-ID: <8021be4426fdafdce83517194112f43009fb9f6d.camel@surriel.com>
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
From: Rik van Riel <riel@surriel.com>
To: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
  Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton
	 <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>, Michal Hocko
	 <mhocko@kernel.org>
Date: Mon, 29 Jul 2019 20:26:41 -0400
In-Reply-To: <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
References: <20190729210728.21634-1-longman@redhat.com>
	 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
	 <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-lY3NRPxUErEaURZG51iL"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-lY3NRPxUErEaURZG51iL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-07-29 at 17:42 -0400, Waiman Long wrote:

> What I have found is that a long running process on a mostly idle
> system
> with many CPUs is likely to cycle through a lot of the CPUs during
> its
> lifetime and leave behind its mm in the active_mm of those CPUs.  My
> 2-socket test system have 96 logical CPUs. After running the test
> program for a minute or so, it leaves behind its mm in about half of
> the
> CPUs with a mm_count of 45 after exit. So the dying mm will stay
> until
> all those 45 CPUs get new user tasks to run.

OK. On what kernel are you seeing this?

On current upstream, the code in native_flush_tlb_others()
will send a TLB flush to every CPU in mm_cpumask() if page
table pages have been freed.

That should cause the lazy TLB CPUs to switch to init_mm
when the exit->zap_page_range path gets to the point where
it frees page tables.

> > If it is only on the CPU where the task is exiting,
> > would the TASK_DEAD handling in finish_task_switch()
> > be a better place to handle this?
>=20
> I need to switch the mm off the dying one. mm switching is only done
> in
> context_switch(). I don't think finish_task_switch() is the right
> place.

mm switching is also done in flush_tlb_func_common,
if the CPU received a TLB shootdown IPI while in lazy
TLB mode.

--=20
All Rights Reversed.

--=-lY3NRPxUErEaURZG51iL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0/jsEACgkQznnekoTE
3oOE1ggAg1gUM2xB6saQQir2gSvZrUyxU6Zo52SS5CmO3mkJP2423lRU37awDIez
nM76nLTpWiME/vXpMA3lzHxnCcQ0uQuXOt9JvXUn3Cn1C+fd6sAC7NjD/aCMEnam
AHSk0qRNcoiwN56n3r5bVlkBi7UymKO+NLXA2hlMLNl9vNKRGYshbo8b44h2Cv6M
Mbbe2ap47z5siyZUphm6/lbK1hZlNLXuf79CCYJDEKzuqXac4ij0RUieOkWpgJxw
4SH8meLRYykoIj2PPFCELl/urg/sIaDQlVqLd5G5ejMMrBQDKdfb4/coCdnhqL1l
0jCbfSYDSxlucg4rvV5J1zmjT9pTEA==
=dova
-----END PGP SIGNATURE-----

--=-lY3NRPxUErEaURZG51iL--

