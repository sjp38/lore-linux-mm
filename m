Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D374C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 07:43:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0922D27849
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 07:43:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="dz6U9i92"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0922D27849
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9125D6B0006; Sun,  2 Jun 2019 03:43:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C2AD6B0007; Sun,  2 Jun 2019 03:43:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D7CD6B0008; Sun,  2 Jun 2019 03:43:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4966D6B0006
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 03:43:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x20so3731702pln.6
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 00:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=3UInlm2FXqpEJ3o/vaCrVVim+J5Po+MMsWbJLQ5mnhg=;
        b=EnCdidheyYVxX2R3iiiVxbL/6y/X/XnfW0GKkyeEAQmlarySmHhr+Z5VOuL84x1U83
         vn6xPpoYkBW/fvDw/g+10GvIlHe7v4DDcQcRTFzMYccSmpjpQtKIv27s5w+MEqgdIvF8
         p+F6hFgDiMMfHxIPu5vADyolQmq3osjCk7w4H05rvbyYgHKEP5n68iFgryi590r9Q02r
         3Tp3nJ70Hl5v+er0Jw4ZnZW35FR0PaRM16NPR0pVippWyuKgsuH7KOfupROGhlKcGKTh
         i6wPh0AXORmamHm+3ycAbSMS/HZgB3DfkV3YQh6AoZHKlLnk1PaLGQVXCorL3jz2UytM
         vVBw==
X-Gm-Message-State: APjAAAWaz/gx2/BtU5lttx4TGQL68TvwFWKgvBycK74IkcyLetKRgOOq
	f4q12klN8qFj7LVkFFIlDZWhzuby3WyerB6bsF64mQatcL2/QvOzLluXRdneAw1PCJvqh16x/6x
	RcXL6gzymzD/rH6XeKbHHyCNlGLsqetyH+3ovrjcsX1pUVcUkKW/3ftdU/Ft8qnEFHw==
X-Received: by 2002:a63:2c01:: with SMTP id s1mr20327618pgs.261.1559461401871;
        Sun, 02 Jun 2019 00:43:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLLN8gslmA99FrvZ/3wTTvFeqvLrwo+KmfQsHM+MWpFLM0M+5BrJxo5ILBODMVUCYvoPNb
X-Received: by 2002:a63:2c01:: with SMTP id s1mr20327590pgs.261.1559461401178;
        Sun, 02 Jun 2019 00:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559461401; cv=none;
        d=google.com; s=arc-20160816;
        b=Ea7HBvCDy8AfuCJI8W5rA6YgKOkuauz1zAqv4h1ANpbHSQn2v4QqsrDfcDAaG3re3R
         o92l6zsOI90xCD+ZaLb/D+WIFpYWKDnbbo9UDInn34W8QxxUydVp4uRnTum+hh7mLAfq
         NMbydyHbVgUm559S5Zgc1cFQ9EVIsa6JGo4HLKTRrOvPrCjnx4X8Abb6kHDXM/LDBXw8
         CQTt3kaWD3+G6vyMVp6kooeQ4hdzoVbgRZ8AYQY0PQmz9NudKDTkYeDkfxOX80N13ped
         vIlY6F96LH2jQ/aWUsfQXmpgjtq3TuQcntUEZPtIg5BppKmT1LAMNBLY1ys/Ku9r96H0
         fOfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=3UInlm2FXqpEJ3o/vaCrVVim+J5Po+MMsWbJLQ5mnhg=;
        b=Jf/Z3A0Uhw9+SYYZkz/D3tGP9Z4W+O7wy9KwN2G1lkEtUE0tghy6oWhatAzSQxqp0O
         MWj5okUqE9Yaa36Pa5ufM2YetllDTuesrBrv7ZUj41BNr/KWny8/abzneSwrAJWlp/f8
         p7NPPYXYbrR1wqrMSBjPsbSjCEP7Kg3m49P7/wA8G9AqeQ1oCpeYW7GNAnHkKqM3cy3r
         hnATVH0bWq6SDIq8NKbkB7Ars2Hi18F9KWif1+QUeDD82/6jCfb+mmnILp0alVKuCo9E
         it7f+PqkwSGUmsZnD1u0OC4E179hX2Pj9MVB8wybDL7Y8MClojOAkHeIsxQRuvgoccsE
         7CDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=dz6U9i92;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id f15si14034520pgu.218.2019.06.02.00.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 02 Jun 2019 00:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=dz6U9i92;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45GqtD6JBbz9s7h;
	Sun,  2 Jun 2019 17:43:16 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559461398;
	bh=F8Z03J2A0Vq8wxMo0qN3xizMzwNq2WP/RD8FwvQycuI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=dz6U9i92Hx3/eBAVYLecYdEBg/uLEv1mbQISn0scqnlmDzw3v65QVQJiPdk73WdQV
	 yR2o/UtaY0iJWQDYJYj5fofaHADJuFibp9rBwSETScaUjo497cSNGP1CPiuiHSpG3m
	 YlYJ2SDWXs68dvhAFTeTmHf2Tzf6DbKtAUhf+fWrCut1IeD/n1tVyJryktd4iw69el
	 4W3lC2otfogT+ECln1iYwuR+xycjethmkSWSnfZJKMxIpycK8H5ibfclyLtWznxQYm
	 IPCFebQd37Waiw4nFA6d45w2ikl0mW5qT9ohu2gm4aNIQEIH8eEUY7seaLd8T9k+eD
	 LnYYfHDv73dfA==
Date: Sun, 2 Jun 2019 17:43:14 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Randy Dunlap <rdunlap@infradead.org>, kbuild test robot <lkp@intel.com>,
 kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew
 Morton <akpm@linux-foundation.org>, Linux Memory Management List
 <linux-mm@kvack.org>, "Sasha Levin (Microsoft)" <sashal@kernel.org>, Rich
 Felker <dalias@libc.org>, linux-sh@vger.kernel.org
Subject: Re: [linux-stable-rc:linux-5.0.y 1434/2350]
 arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to
 `followparent_recalc'
Message-ID: <20190602174314.09f5f337@canb.auug.org.au>
In-Reply-To: <871s0cqx33.wl-ysato@users.sourceforge.jp>
References: <201905301509.9Hu4aGF1%lkp@intel.com>
	<92c0e331-9910-82e9-86de-67f593ef4e5d@infradead.org>
	<20190531100004.0b1f4983@canb.auug.org.au>
	<871s0cqx33.wl-ysato@users.sourceforge.jp>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ZHlU6.H.HMslp_9vg8BHKKd"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/ZHlU6.H.HMslp_9vg8BHKKd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Yoshinori,

On Sun, 02 Jun 2019 16:13:04 +0900 Yoshinori Sato <ysato@users.sourceforge.=
jp> wrote:
>
> Since I created a temporary sh-next, please get it here.
> git://git.sourceforge.jp/gitroot/uclinux-h8/linux.git tags/sh-next

I have added that tree to linux-next from tomorrow.  However, thet is
no sh-next tag in that tree, so I used the sh-next branch.  I don't
think you need the back merge of Linus' tree.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgement of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
        Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

--Sig_/ZHlU6.H.HMslp_9vg8BHKKd
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlzzfhIACgkQAVBC80lX
0GwU4wf/aBm9zCZTK4IW6qEhed2uiOXRANwzjz1TKPGrQh1lNJCKSeS1fgWIstla
+4dmvKdPx9K8dvTKI0nkp7KGgdrIVTRgkTejZDRnDDd4M0DIV1EidGnsN1desUEO
/bWJM/DfRaxPEBxhc3LHlpwG2we25+1mGreUAioMQ2DHC+gkWUVoLSxWWUcTW/9R
vWPuBZBjdZ00a0hIxM5/z7fz6kO8LcVf1dq43mDibeC1GLxM9GlxdHxH26VV0gjG
L2nT+xMitj3pihFHMJY54iR5+E8TXBQcMbft/Q/OFY+69yks81eavH+kyCAlmkzO
U8ahAGUUe5wbQjeDwzJk5rLjuJTCGQ==
=0sdq
-----END PGP SIGNATURE-----

--Sig_/ZHlU6.H.HMslp_9vg8BHKKd--

