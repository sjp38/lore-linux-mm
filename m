Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9ADAC5B578
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 04:10:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7086F20656
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 04:10:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="ZgAP40Fd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7086F20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 126418E0003; Fri, 28 Jun 2019 00:10:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AFCA8E0002; Fri, 28 Jun 2019 00:10:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E92778E0003; Fri, 28 Jun 2019 00:10:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2A588E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 00:10:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so2999653pfa.23
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 21:10:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=I55zkrMesqKne3KNEzZE8U42iz5xAdNYBrsAy1XmwNg=;
        b=oKNOv4cfuJMML6+J+olxBEDr4ZSoKX68zozjX21QM4VdXD3K1oILoSSFBS9Ed4rrq4
         79ciGPr7QKVbsgg48veusLT40Yo0LGUIkNSq0ynlTbnVMmEzenruv522KO1buZQGt0Xy
         wK22FNB3lvzD+it4TyZDiQiSs47Y/w4PankSJ3Rx4rUx/XTtS6S2EJ8ozROr2G4TSPzk
         laj2FQnNlzIU2RNDLTOS9PKsaGu6ik4ak7GNR5ZI5B+cbvTagrZaSLp/OlE4LVOyyDu8
         7n0RdNyH6yAztoyycFtP0FTMliM6W3GAt5J842EToagTHyz2BrFpguN+PyMWU1DdEfM2
         fVbg==
X-Gm-Message-State: APjAAAXYav6ElMqAF5rQP2GHH0GxFoRBJ83LvyjNPQCH7fa91z8RNGX3
	6LcNIpznNCnicS08SP+YrKz2arO3kNc2KothYpSG6ego1BHIuZJnzLBsQhuF6N1aK2vCSyzhyA7
	AsqGLkajvKBH5g9yYqrAsIFYaeiGYaKFlFTRyIiqVxo0F/6JNQrBrQWbP6DYvyVllIA==
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr10317735pje.125.1561695023263;
        Thu, 27 Jun 2019 21:10:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo4aaZCcTNPpfoopwB1DbIzzr+6cRSbz48qXG13cntbFWfKvBfGBM1FurGZslmUIN2FifF
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr10317680pje.125.1561695022674;
        Thu, 27 Jun 2019 21:10:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561695022; cv=none;
        d=google.com; s=arc-20160816;
        b=p1+AEI+aaZ9KaZCb3zPDvSGZ8rwnf+UnkAdPYdyWyGFHBFeYKDt8NJxWo5svINmFZs
         PqFIo6vD8mR7NMwn8/4YDnmzujRmTS0F2quoLiVxrS7RiVjKCF1DSterLXOwcbcZtChj
         jjbiryr7I5luIur0MTbVzvh8UlppbVdw50csaAIYLVnCca+suYFGxvAC7IuFzVECvB19
         ROTVraiXpwCvDEurOLXsNm76tMnS3VVZeQ8+FJeJ2BX01EKUIIlFdDpGJcwpftsE6v/c
         5ZRw3vkJdrUFrs20p3zE26vYi9EXAyn/hBhBKCnlri4Q9LeKK3HqemdrKMAQP5e/HfIy
         rtdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=I55zkrMesqKne3KNEzZE8U42iz5xAdNYBrsAy1XmwNg=;
        b=ZmRzHG2eVsnBl/DDK0uqQ5xBPkxQpCHkVlBIT9KJpbs/tj7+1gFebBYBTKl6M9/Dxq
         GQcdUdQ5FHUwxRqzqlmqwK35y+qz0kIFpQ8qr16sKmRje/O/w6mq+8NgjAKnFbd0hA/D
         Ku+yMmHTQ2XAXxqMQCJCwnAT4XSvJdW/iXZ+dd70YSUOZyWhe6HjoIxJtZCsZ/1RPjDL
         r2ASvsnUg4njjkvJwNcNjITNo+KgNbXWUIYXHBpx+2BiIWme5EppmSNY7yfqUtcu8fwL
         V0fHo29dkwhS+PUJED0xFpBAYmid5eTKLdXP6gJU1EiWXWWqcNJ3OnoS8I5BNl+y/8rw
         Y4Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=ZgAP40Fd;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id b20si1185106pfo.108.2019.06.27.21.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 21:10:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=ZgAP40Fd;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45ZjwW4qpwz9s3Z;
	Fri, 28 Jun 2019 14:10:19 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1561695020;
	bh=I55zkrMesqKne3KNEzZE8U42iz5xAdNYBrsAy1XmwNg=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=ZgAP40FdlZjb2yEhOECndGyeLh1QfrT2/DbfoBVqZy3lC+bAJCo+Xa28DynCRqdBn
	 EUS89x1QjDGxmVnVe7ZSwoduC5otYHiMeR5FCaZCyJxoRiLzyElm9QP6nbisMT1DA6
	 mrEa5DsH3PUg03A5Q2OOWbBhMGRpHo8Wy4oSV3DJYLttTIfBpFtCAhIAvMCTwCEBHS
	 +RWL7nKUZVjDDh3uYaOytL5fBnRaGws9jyD2r2DPCL3QRFM1/n8qer7OgkUSoY2SYC
	 jSrshrGn+4SJ5ZeN+eZeW0WwppwwSdBvJwETBB3smrnqwEdB2ncwdYCClO5bSk0YN9
	 OtGx6H4eqjorw==
Date: Fri, 28 Jun 2019 14:10:18 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras
 <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Nicholas Piggin <npiggin@gmail.com>, Andrew Morton
 <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
Subject: Re: [PATCH] powerpc/64s/radix: Define arch_ioremap_p4d_supported()
Message-ID: <20190628141018.5ad2603d@canb.auug.org.au>
In-Reply-To: <6d201cb8-4c39-b7ea-84e6-f84607cc8b4f@arm.com>
References: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
	<87d0iztz0f.fsf@concordia.ellerman.id.au>
	<6d201cb8-4c39-b7ea-84e6-f84607cc8b4f@arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/wq/1diQb=+V7OS3bGVMftw9"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/wq/1diQb=+V7OS3bGVMftw9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Anshuman,

On Fri, 28 Jun 2019 09:14:46 +0530 Anshuman Khandual <anshuman.khandual@arm=
.com> wrote:
>
> On linux-next (next-20190627) this change has already been applied though=
 a
> merge commit 153083a99fe431 ("Merge branch 'akpm-current/current'"). So we
> are good on this ? Or shall I send out a V2 for the original patch. Please
> suggest. Thank you.

Please send Andrew a v2.

--=20
Cheers,
Stephen Rothwell

--Sig_/wq/1diQb=+V7OS3bGVMftw9
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0VkyoACgkQAVBC80lX
0Gw6+gf/Y06x3WT9WXSTWwMk6GeiltDHujuBd130HVkWnVGWvwg8RQc9/VfvqINS
XV0T6wzeSBWrWx5oPcbhTjvWy6a69nYs6x4gxHE9WUWyg5NVK8qFwhQ7h7oQEgDq
hHSxZ29YSp8yx1SN/JG7Lsebpkfo8JHbSLI6e7icI4odv/D/p6WeOgJI2cIGvkkb
PJaw6nO/shGvtqI9VyLHlcut0Ay42x4/jvXwrPyZWYJpdJ6I2ssw2tXFNzMHAiJa
k5Hj69KXCXolZ7fZlYUmf+zMA0EcMvGIWjoa/rwSZYwnrRc0mYAMburImlu4FnCT
u+TtTQ6frusmg5BqSfuN3Z7I9nFz7Q==
=PTBt
-----END PGP SIGNATURE-----

--Sig_/wq/1diQb=+V7OS3bGVMftw9--

