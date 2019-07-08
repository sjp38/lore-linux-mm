Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7575DC606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 15:35:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A03321537
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 15:35:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="euW+MCES"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A03321537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94C888E001E; Mon,  8 Jul 2019 11:35:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FEA68E001C; Mon,  8 Jul 2019 11:35:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ECCD8E001E; Mon,  8 Jul 2019 11:35:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2458E001C
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 11:35:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o19so10700163pgl.14
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 08:35:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=vxyFLSfBBJH3Y7Nv3aQfVqUUWv+pTXtM/NKogMH9qnM=;
        b=dDKWd8puY/z7VKrrUFqlLxI191JvCWvnkv/bMjDh7/U2zgTNdrtNmz5ri2FOijSF+U
         FwYcZWuhcbZ++Zc6Msr+hWxybx8MM95Xb1UaPh7Kt9ikjMInQGReGx+9WEHJZaj/uo1s
         Np8lbkuRx1tWI8EU9R9/jy06LNIWG4a2uRl65AFSDS+9PHUom4sPTD+NNVaxSZkTn3Zk
         8K7PT7R2HimUUraVW68kugsf2IBGD0eIEG8QFAh7GfLG8+PtbQc7Jom8NxrtWKimZJQ9
         VOgxAtBt22/PgpYu+B+1j0JlqtdCbJeV3ji4uskHYMAytdtwAbENFs6ElDFoyuhWzuL9
         N5GQ==
X-Gm-Message-State: APjAAAU4i+zhn8YLECSsN5skYW5uomZNLvR2Wgo7r1Efu6qOY5k5W9qK
	vIMgldDX9DzqP7SRMPWcg4k+rEEyT2JWm/mLmwYXtv4wxquspFQqNevPBcOKqeLTUUwVfdnoM0s
	rnnzQzFTgN4CN8+eDpikXH5lBcK5pS1bbWU/XEcyEfX5SS1G2beQRutVGcbLQywm17Q==
X-Received: by 2002:a17:902:724c:: with SMTP id c12mr23570004pll.219.1562600130856;
        Mon, 08 Jul 2019 08:35:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrJpxGunesArZikTfo142K7PF9Srrbg0NJVarZGVJuj1lKQhuvQ32YwiLCG48gUV8PF/+o
X-Received: by 2002:a17:902:724c:: with SMTP id c12mr23569924pll.219.1562600130105;
        Mon, 08 Jul 2019 08:35:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562600130; cv=none;
        d=google.com; s=arc-20160816;
        b=rWrAG1M0XYxoznnsHcO+LlBdM8O5qaAFQFkktDxBWdKkBpfrQT1tEXKcPXl3x/fArI
         mIOeMhqkEoln5I5aqE31dO9D4yN9kXkGJsF8GGt8aBQDB0juj/jMrSnmmUqraavUaZFT
         TW10Pryw5BOM2Vx/52h3i7XkdkegaAGYnjskucFl0aMly94dQOi7szKtHdc3DkZFlqHj
         2TcU19Bcc7YBfbhgNFpaoEC/H0j+qKmbWRgqh1AKe2O0Lcn9pXXP6e/aBSkn6qJKVukJ
         zp+xAEEMTECK0EhyyJuqLaaVfLWoE8AoD+lhAnpStYpseNpoMxpzGiiMiJKFjcSWSTMy
         l7sQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=vxyFLSfBBJH3Y7Nv3aQfVqUUWv+pTXtM/NKogMH9qnM=;
        b=ATuZSv0sc3/6DSMuvhy3Ax09v3yXI60K/DsBgN4QxN32kzT6GkOWOLlmxiY0NmsiL+
         M1RW4FnfrLCTUn/LlPbfONmU8763+q8Hlue0ZvRZjw1A56YswgrMRIc5EhAf4ZtHAe2R
         hExe/xJ3lBMNIZMXcQ+w/FoxRssza+5pMK1aFYdwrH537iBIYU55Nh8HY7iselzDB61i
         E+qOtYKn3Uxo7yBgvTYupZst4I0C/SukvRNKNG6LNo6RlWgoydbC9fcWSXlq+cDXH8W/
         sssVH+myMDgC9te3VnMAqLNg6bEs7mQf9gMMeRAcV+fkjAtp+egtZXplbHssWEZbzFQg
         PTLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=euW+MCES;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id t6si9944892pfe.231.2019.07.08.08.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 08 Jul 2019 08:35:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=euW+MCES;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45j8fP1132z9sSR;
	Tue,  9 Jul 2019 01:35:24 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562600126;
	bh=vxyFLSfBBJH3Y7Nv3aQfVqUUWv+pTXtM/NKogMH9qnM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=euW+MCESXPYou4FtkhvyThpXXET7NbT8ySOU71wo7oL2nKP2wB8DWLzcDKoLm0pkz
	 JZ+4DlJwZzaKNc4k5RMASCxfI/Vg3AXQtWKMp/ASmNrOYcxSJzN5lcZlhbe57P6iLu
	 a09EHfTChTBZZS86N9B8oGfaCy3lsBT7ll+wf2oighG9jD0QcDWls3D06Z07I/mtwC
	 6ICU3UeAon/W3ov9YNqL4Z+VpJY71CA8YksURZaUCLPvssrLiNYdvGdAnE3u7m7TD6
	 x8Jz5pNgRMzTyXOt63xFdh+ok0ThKHgE2iWqcQgzqf7kp5tZ/aTa3fXzjc2090db9L
	 3jeB7hEyxDDkw==
Date: Tue, 9 Jul 2019 01:35:22 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: Alex Deucher <alexdeucher@gmail.com>, Jason Gunthorpe
 <jgg@mellanox.com>, "Yang, Philip" <Philip.Yang@amd.com>, Dave Airlie
 <airlied@linux.ie>, "dri-devel@lists.freedesktop.org"
 <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, "linux-next@vger.kernel.org"
 <linux-next@vger.kernel.org>, "Deucher, Alexander"
 <Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Message-ID: <20190709013522.060423df@canb.auug.org.au>
In-Reply-To: <233ad078-50da-40ed-fb35-c636ed3a686d@amd.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
	<20190703141001.GH18688@mellanox.com>
	<a9764210-9401-471b-96a7-b93606008d07@amd.com>
	<CADnq5_M0GREGG73wiu3eb=E+G2iTRmjXELh7m69BRJfVNEiHtw@mail.gmail.com>
	<20190708093020.676f5b3f@canb.auug.org.au>
	<233ad078-50da-40ed-fb35-c636ed3a686d@amd.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Rz_UKoCs8b6c77s_a244mIn"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/Rz_UKoCs8b6c77s_a244mIn
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Felix,

On Mon, 8 Jul 2019 15:26:22 +0000 "Kuehling, Felix" <Felix.Kuehling@amd.com=
> wrote:
>
> Thank you! Who will be that someone? It should probably be one of the=20
> maintainers of the trees Linux pulls from ...

That would be Dave (pushing drm) or Jason (pushing hmm), or both.

--=20
Cheers,
Stephen Rothwell

--Sig_/Rz_UKoCs8b6c77s_a244mIn
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0jYroACgkQAVBC80lX
0GwppAgAmx7mlSoT2O2hM17aTOjMDvnqgZyqhmFembgdQk3DEyWJR3LOiZL/CgM6
iYn8A7GbtcH8vNwWB/eynjJHALs2jPcVqWu69kYAoPhDvRPNvpc6/ddaSrOKsb52
3z9K4sXwA8L9t9H0LrgSB2Bs34yL3XvULPB34Xf8V7iAnyQVx+WQ4EVTfjITxoXQ
Mx3oIqRGQ2u5qk7qPfCTCMDxIDRn7nR1qJVSqY1hLu2vnkXpbbKxKk8EEf0A21Ao
T/AqVkClnADvpfhGMAoWeXyVOFCEocpNgm6elo2+EtE8YbVNUeKXbapNg+OW4xyF
3QBceqlPmSiTGaEu3+1WJmlcJKsR3g==
=Joh7
-----END PGP SIGNATURE-----

--Sig_/Rz_UKoCs8b6c77s_a244mIn--

