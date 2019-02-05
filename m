Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EAF6C282D7
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 07:59:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDE25217D9
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 07:59:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="Dzy75dMP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDE25217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 756538E0079; Tue,  5 Feb 2019 02:59:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DC0A8E001C; Tue,  5 Feb 2019 02:59:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A5008E0079; Tue,  5 Feb 2019 02:59:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFDA8E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 02:59:03 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y8so1706357pgq.12
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 23:59:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=9cgS1uUqrpWCB0j2qXQ6JKbKhRXfXbSZdv/fTiax/V8=;
        b=B134uJ1yiN0ZRdpyjcgZzMHpFuWpVIWQyddYBi1587yu3B2x5vyJmNBym6FLm/SpT8
         xsTZylNDizGClz9XggN2tfrquo0hBr5qdRqozHdh/4OQDHYN9CzL01rjGUVYyNJERjti
         uu9/GkYhJwWswZL99y1/w4LVpugGGxhyjIiUlSz2rXXyCNjuGU/1LHKiTUlOlWnIBgeK
         QeR+f/3DMUHKOirMaJcch6MhgaPmk/I4dMI9vS38n02I/nJHdAUVlMluYLpqqXaPvkxp
         8v6/H9iOLusP8JNX0QdRMPJFMVu7Ph4dafdQjwDSN6vmcHtmXGulIeFjSGGaix8gRO1e
         BPIQ==
X-Gm-Message-State: AHQUAuZEczf1ZEACk/GKxNOCOmYyN/OOXeXeusLWBr1lbrYg4vY4Dwhq
	Uy2XASTsHyQe55DC34mmDzfjOpTnuLwKTItcp2oQ5MMyKX5zOXVN+T6xgb8jbAF9DQToKnpTwxL
	DGAiAgawq9yB2v5AcbY4c4NYKT+AwYmresyDO2eLrGBtYEbs4orBKvuy8CnYxHr5N5Q==
X-Received: by 2002:a62:1484:: with SMTP id 126mr3582684pfu.257.1549353542590;
        Mon, 04 Feb 2019 23:59:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaDHSywpoPvBZATDM8UnYiiG2IqQ1/we20MBEUAZV5mNKL47S1JdGlKHEdsdQSn06Ql7EkK
X-Received: by 2002:a62:1484:: with SMTP id 126mr3582648pfu.257.1549353541893;
        Mon, 04 Feb 2019 23:59:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549353541; cv=none;
        d=google.com; s=arc-20160816;
        b=ihUjae93zu39t7jPNKuOkV1iSaIliTg8hDiyPxuIK6Nu+cbVmWrAmiBT9q0Inp+0gq
         fH/SMFdvYE1ILwd9ORKfQTOvGFOjrD9xAm/oZBua6fAyagIZHnCaIh1PcbNLFUP/YOk5
         qblhGCbkMWFk/KUrK9onZuNoeBg52bIhn7NxZ05tQUPOECEbm/NMo8aZn3GBfWtPtAMl
         YptGPQ2w8mvYxH5V9EKkiOgFfeF6aQQg/9hiYy9VugSkgSSBGroINe+OWT1XQMsrgoYt
         rfcna04ppTsYkUU7y/7rLo4gBGP4traFeoolaPJ8y0rmIU8ePxBbKFnhiv1Iwa2Ti80z
         2AXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=9cgS1uUqrpWCB0j2qXQ6JKbKhRXfXbSZdv/fTiax/V8=;
        b=sT6LSB+hMO1fpAHTR7SLL27BMkolWYD4dMQ3exdyyVUdDIzEV/Olatnn779lMMt1th
         hFN6x+fbxQMo3/yBGvsNTUuEoR81zIZFApfqfZy8eQCCd7WZcifDFk/+FTNkf4Mx3gSA
         OFjS9EHmzEQB4ZzE5gcxJC1BNfpmiKpa7esEidP/PTNbseraNPC7qog7Pc6NIP8YTZKf
         hP3glvDk2qes5rLeKcb/gG9mhdJWcAXIjHINpkBGpTCxNOPGkuPtvdtaCD8iLgUBXcJP
         KRVTrdy6bc3zCiMIFHl3PuMuCVlCmRMj2W9oIOMyM5M9b87LmvB8ZA4oArPX2jXOiZN+
         qIKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=Dzy75dMP;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id c4si2411767pfi.110.2019.02.04.23.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 23:59:01 -0800 (PST)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=Dzy75dMP;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43txmJ59Znz9sMl;
	Tue,  5 Feb 2019 18:58:56 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1549353538;
	bh=ghOAZ/F6trDoGLk30/T2NZNm8VxGZcg+V9sKElMNopA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Dzy75dMP1yW2knnb95S/OGQpVLTupqgn1sOpMelyGhVykjxnGOaX4XbZctgq0Q0CA
	 N24GIkdcM1k2WPv52N8mWI32rykwA5GsDsfL4xogXDGfz4ASt+7tcebmW/IzCok7Za
	 thtrQgVAo//vgb9kTiwsf47QqxGHtzvDPt18C1NEyNiIoCAV2zWOsCdr6Hr4dE/YML
	 GPgsHUKBT14jEuas0GlB96UPEA8xFiz0KmEFkyphWDH3gI+Et88jK0wu+tnnZinpJc
	 WBtZoxnGMC+h7OdiuwrvTvBN3vdk5unFcXZQqGWS7Bmco6nWxNEKVs28hxmdnkNrYM
	 TgbzxSwU6Bv+w==
Date: Tue, 5 Feb 2019 18:58:29 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org, Richard Weinberger <richard@nod.at>, Alexey
 Dobriyan <adobriyan@gmail.com>
Subject: Re: mmotm 2019-02-04-17-47 uploaded (fs/binfmt_elf.c)
Message-ID: <20190205185829.113a8812@canb.auug.org.au>
In-Reply-To: <08a894b1-66f6-19bf-67be-c9b7b1b01126@infradead.org>
References: <20190205014806.rQcAx%akpm@linux-foundation.org>
	<08a894b1-66f6-19bf-67be-c9b7b1b01126@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/+HD3eexliaqabC4pbA07JGT"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/+HD3eexliaqabC4pbA07JGT
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Randy,

On Mon, 4 Feb 2019 20:26:43 -0800 Randy Dunlap <rdunlap@infradead.org> wrot=
e:
>
> on x86_64 UML: (although should be many places)
>=20
> ../fs/binfmt_elf.c: In function =E2=80=98write_note_info=E2=80=99:
> ../fs/binfmt_elf.c:2122:19: error: =E2=80=98tmp=E2=80=99 undeclared (firs=
t use in this function)
>    for (i =3D 0; i < tmp->num_notes; i++)

This only a problem for !defined(CORE_DUMP_USE_REGSET) architectures,
but a problem none the less.

--=20
Cheers,
Stephen Rothwell

--Sig_/+HD3eexliaqabC4pbA07JGT
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlxZQiUACgkQAVBC80lX
0GxwRgf+P5QlePLLQEgqvTRa0Shz+SodC89zAUfN8U46W7XmYSmMjbfH4en9aAS5
LRZFLYwLDb0pTF1BKACQtmjcpSB981/iXf4+S3lGDdqL12eY22UCb9TkYArOGXhD
WJSnzABFZULOpnqbVwG7tLDSo0sOpoPEaaYPg1T++tLRDuryfgU0sdBtZ6kmUGjf
ktmuUnHfg+L0YEhPEOOemnb3/GV2m/R7ei2YpCB5J8I+WuBVc0exO14N6A09x3Qc
vDKgDkk9LTUzfzcBo+jlUjI+RoOOzE3dAEX5u1Wx3BIcSREWlUi4AWjaxatefXdY
qMw62ST26RJbtBiewhhTSIbCEpts7A==
=QLXe
-----END PGP SIGNATURE-----

--Sig_/+HD3eexliaqabC4pbA07JGT--

