Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 927DFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:09:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 817652077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:09:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 817652077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5E468E0004; Tue, 12 Mar 2019 17:09:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0DDF8E0002; Tue, 12 Mar 2019 17:09:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B26108E0004; Tue, 12 Mar 2019 17:09:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 867858E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:09:14 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h11so3356928qkg.18
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:09:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:in-reply-to:references:date:mime-version:sender;
        bh=rI5ap6mkrGe8GVinQyElyBzzUSKIlMHijrNgy0Pm1a4=;
        b=rHh5yyAarK2VqJ8quOOf/gjaYcGPWVj8JYjZXaQhS85m7d+2FfaPOzaOkW71unsIOm
         1638fbd4kPvX0+6ZI4vSQlYPCqZsswELECV/hUmTw792VN4gTa2F7oReAtrceK+R+8HI
         z2y2Icv7tALwoxxNLH8qQIHmmxB8tSo5VVfgzftLQ/CnNC2Y+erepcvb7jGe84IrxN52
         VdvlOPzPJ08lIBB6vOPjZRh2TV7N5kRAtnb7K+kUCVkpkmpTK708CVFfRCU+rHXp/1GN
         C/dKQ7ggacjSYpSvyMxZrvYVhu3v8cjjQi1c9PkmUxwGGtJZUtIuaYQneV7JTxW4Lyk8
         zWNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAXUBFL/du13zZ5MsD8gIH1ByXx6SFX5bZbFAAIWCzX/GIYfUfCc
	y93Q40imJFiXnCUFOPPm5W7P8YJxtJ2KjMWv7uHPk+CfiAe3zudbHX338OYTBAEjkht9vjDwDeB
	tpH6Avff1Xum/FWmn12Mpxw8bi/GUhsNKCGtQh4xt+IS24ZXFKYK9AoY5Na2Dq7dgpQ==
X-Received: by 2002:ad4:528a:: with SMTP id v10mr7869422qvr.89.1552424954310;
        Tue, 12 Mar 2019 14:09:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOa+BxsIw+3GnnJl02aEcAlJD9YWz1kj6f0sPm4vW405kYhXItN15jCty8rIUQQtn+hopa
X-Received: by 2002:ad4:528a:: with SMTP id v10mr7869387qvr.89.1552424953746;
        Tue, 12 Mar 2019 14:09:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552424953; cv=none;
        d=google.com; s=arc-20160816;
        b=0QsJXwyYltKQV4OUeyV5dMN8iH+bnpbxkFD1v0ZBXJ3cB5m94TXBgx1zq/6GknLGZF
         CPi8j65up6wKE4E005uHZ78u5afUf7O8xiIX6nf64CzABarUQrJ+L3EZ2O4/plvqbLf5
         l24VXQB1yNxCphIZEDuckI+BIR2A0YPUgAsUHFCrYew1VJz0FLz72mP+xGGhC3VnhVWn
         k8jXR2D8BDBpcEcgtKBOAJb1dZ/4/Qz40D4X7KUFIuSlgfH/LvcwMAHtbd/Xo5uwZGRq
         g8dZwJG5eS5z66akKLvdGEcxva9COXr4Gp1vZ84rB2iaFDYYV+iE4J7x+HefTTmejP2h
         8SNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:date:references:in-reply-to:to:from:subject
         :message-id;
        bh=rI5ap6mkrGe8GVinQyElyBzzUSKIlMHijrNgy0Pm1a4=;
        b=xLM0BUxw5uDr7KGNoURP+vOk2I2DNo2YHcINvWyB6V14Xrr3B8yLUTDvYEyzBUGKaP
         T1u+MPIt+4ZSG1CCguX4HvxKeKzibd+wFM9uDWsSDZ6yPwgCZ8qjllCEKdbUe4xlfGFe
         MT61Ii1WcmTZdlp9dR5wIVPyKYmc8GK6vY6gc/oMM4uQEO1jOrfIb8RtrnPlBOKwQR8i
         4IRaIN34CZT+/eGAH+0WnuevMHQuL+95eBsjygGxwBeUVBcK9qd/O6ZYRBt19SYeAVDo
         e5jGVwmQocb+mEdytqFtNfCE41rBV18TTfVSqELJblNgz7H3Z7dxHzz97mLGPRtgjFjV
         ROQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id j50si6034000qtk.7.2019.03.12.14.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 14:09:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1h3oe7-0005Sp-06; Tue, 12 Mar 2019 17:09:11 -0400
Message-ID: <a0bd108182aca3d41927819be09405e1d048a77b.camel@surriel.com>
Subject: Re: [PATCH] filemap: don't unlock null page in FGP_FOR_MMAP case
From: Rik van Riel <riel@surriel.com>
To: Josef Bacik <josef@toxicpanda.com>, akpm@linux-foundation.org, 
	linux-mm@kvack.org, kernel-team@fb.com
In-Reply-To: <20190312201742.22935-1-josef@toxicpanda.com>
References: <20190312201742.22935-1-josef@toxicpanda.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-683ghCUDNgaxptg4V6Lv"
Date: Tue, 12 Mar 2019 17:08:50 -0400
Mime-Version: 1.0
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-683ghCUDNgaxptg4V6Lv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-03-12 at 16:17 -0400, Josef Bacik wrote:
> We noticed a panic happening in production with the filemap fault
> pages
> because we were unlocking a NULL page.  If add_to_page_cache() fails
> then we'll have a NULL page, so fix this check to only unlock if we
> have a valid page.
>=20
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>

Reviewed-by: Rik van Riel <riel@surriel.com>
--=20
All Rights Reversed.

--=-683ghCUDNgaxptg4V6Lv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlyIH9wACgkQznnekoTE
3oN6jAgAqTu+s2gKCRXJoaObMpfHImpZhZ7V8zUHpj0JazUpYUHXRzUrzt3jCLMj
7v0daqn+w9fnxEeJ9ejKogs5WjHV9dRKfG6l+odEJqHnkW4xCG1GQnVdOsLaM47j
J5T8TYb/NbjmdsZ9iVugKdA03toAbWEf4dEm5X4iRlwDcpQdZFUJ+7XKIUOJnS41
NsBeg5M5jH895QAgUSzu/dCpUDx5IMu6o1VV3RqsX4+JABOrQzrjOVfZh0lBQHq+
Vel30dsbLCuteca8XjP5bHsva30aSHzJaZ+SrTnsZrMNljMd10fZM4HTZCmbuJu4
banfl+UjWGZEUFcypgAJq9Bt2xf1MQ==
=jXvC
-----END PGP SIGNATURE-----

--=-683ghCUDNgaxptg4V6Lv--

