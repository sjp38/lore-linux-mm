Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E148C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:29:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7151A215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:29:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7151A215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1290B6B026D; Wed, 12 Jun 2019 13:29:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DB766B026E; Wed, 12 Jun 2019 13:29:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE46C6B026F; Wed, 12 Jun 2019 13:29:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8F76B026D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:29:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k15so26913616eda.6
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:29:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dCHCeocAmL6meM9qjy9P1A8GdY5XSX6cnD5creDeSTs=;
        b=bScFm8bvTQS7epN/8D7CxOuK4gaJtObAT7hHe98GyVR7bU19BJN8NVbPynTpNGCtEn
         DfxFaVd4pwQHLToBtTogujQmJGT73HMXt5b05cyWUT8fuLLiRQifbZeB40oa/RhpIit3
         0Q76btmug0mtx44xEU2Zkhm4T2PNcS7dBx0NaDWCA5Ubm/Js/w/iMZvYm4vq2BntewOD
         PmybibNM8sL5Bu2QA0lM76atkOUAskA+yA13O3a2vgV16iO6raMVoy2Hp+sxiNJBY95e
         Y+f24Z1+QE+xjsgzF5J1cN56QOQqDW4SXZYCjvnLw5RomkWkzH8O8SVvfU3JqlwZgEMI
         wLew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAUPEMr2q44g/fit4IhKJ9azcxoWpmzJaJAFHKw6h6VAh6lQoN5j
	1N1WjjG/gDRLP1Os7QsCIp9HomVxqjpc373FW2nbGe3PGl1EIguA42MEcDpXfl3WmtrruwbIkmz
	dgTZj4UKJFBhYAZaPUWArDgmKI+xcRrVPRNdWlJYjTaauGyNWSDZmTYuyY3qyrXzuLA==
X-Received: by 2002:a17:906:5210:: with SMTP id g16mr50826068ejm.148.1560360558205;
        Wed, 12 Jun 2019 10:29:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfERhK0WhKxhJELr9NcgkIS1zwIAUX7ghnF1QeNBaCSag1iGfsX7IEr1xTY7++371uaP8Q
X-Received: by 2002:a17:906:5210:: with SMTP id g16mr50826004ejm.148.1560360557428;
        Wed, 12 Jun 2019 10:29:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560360557; cv=none;
        d=google.com; s=arc-20160816;
        b=0UpckN4RcIm998xou5OEVTRFERVjlBtdnKcEPAkFCUvvByOZTkpTV8SKtp9IpeXvKB
         ipqZpT9pS3HssA1uCg4hheWGP+OFeJYibgUfWCeV/NM4Eti5oBKjz4py81OZDdU1i2SE
         FeG4T66fANVbbGcdOdOF+fNpLmRJLudlJUDbN5KFWGAUhO2KHehYmL6VxBDbEwNZVZak
         Ew3/YYoRCsCCGOY+oZNHmf8QKtUqCs/1PAoXttjCIx1XQlVpgG3ympkODfdBwCShKLqx
         BYOi10dzQtMBfAMeYLkOMFMaAS3t5n5iHKa6QG84jAqUb9tJaOjHAXdRRANIRiUqkVlq
         4RiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dCHCeocAmL6meM9qjy9P1A8GdY5XSX6cnD5creDeSTs=;
        b=ZjyMmZgsRyiMqw2CfzbxyllajXkSYdRDrnTRS5EH4auyXC3gKWDUmSlapCJgVGUVs+
         Az5ttwHZsH00ahpTVj8m7M78ZV5EinF3uXOatTIpj+RtX3QQ3l4BoXbq2sAWihwb8t4g
         ZfdT0yvsXTx9w8F5cI5AMEDSr1wijAbOa/Qg58FmOIy8l+ixHkQngL6pF1ylyh7lJhCm
         F1I+/pqDm3KNGlqUr+D47QORckWW1femGmBIFn+YBt0jmC3p28Y8sHWwXClPJyewI8UE
         HDljtOLVQQNrEuellVWnxWiAYmqpQkn1jewY9oXeim9GPr9EON+FSaW4svAc+mD22OEf
         YPHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c3si283552ede.203.2019.06.12.10.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:29:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C45A5AEBB;
	Wed, 12 Jun 2019 17:29:16 +0000 (UTC)
Date: Wed, 12 Jun 2019 19:29:15 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: gorcunov@gmail.com, linux-mm@kvack.org,
	Laurent Dufour <ldufour@linux.ibm.com>,
	linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [RFC PATCH] binfmt_elf: Protect mm_struct access with mmap_sem
Message-ID: <20190612172914.GC9638@blackbody.suse.cz>
References: <20190612142811.24894-1-mkoutny@suse.com>
 <20190612170034.GE32656@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="dc+cDN39EJAMEtIO"
Content-Disposition: inline
In-Reply-To: <20190612170034.GE32656@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--dc+cDN39EJAMEtIO
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 12, 2019 at 10:00:34AM -0700, Matthew Wilcox <willy@infradead.o=
rg> wrote:
> On Wed, Jun 12, 2019 at 04:28:11PM +0200, Michal Koutn=FD wrote:
> > -	/* N.B. passed_fileno might not be initialized? */
> > +
>=20
> Why did you delete this comment?
The variable got removed in
    d20894a23708 ("Remove a.out interpreter support in ELF loader")
so it is not relevant anymore.


--dc+cDN39EJAMEtIO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEE+amhwRV4jZeXdUhoK2l36XSZ9y4FAl0BNl8ACgkQK2l36XSZ
9y4uOxAAjMDNYmUD6lLGAzeXFrP+1e5ZsH+N+j2Qh62Pahnv0oBIbre4TBhAk4xm
av5IPuXrU5Ov5DrRGwDlDP1B2gHbCsvkMxjN+fhrqDRaP9q2y1+UIwKJD66VTxIQ
KiEEiU0uZvikSW4/s4OWstiLxj9nZmiun/YiJ5qVNVuvsfoUjvTHK0BbAN6Vdaab
M80HDqLf+uuERUiaSb8xa5WVB0QViHICBJ2LDfDnVtiioJPn44kPmFwyao+nZJ1T
/RlZ9jFB0UIFSRWIwAxA+qwyWj2hlfT3NC8DMqROJzQDwje6op8keLSWJnwWGMzG
OldDk2uRA5DUi3nliUhp6iv8fDgcryT0IvV5GsphE/LHU/xVMymC0ZkIMksTq4pG
cWU1rnWOLgDpr9BHzP2Zhl7RjSyPUNBojV/hVvo0hpPt2gFgQOlhegKkKl/pURjG
jsLbYKr9aA99OJUEIfk4qK019j6b2If2Ixh5FyXAcxzDpQWIMWAaZdyoFkytnYK9
tKW0uHeCA6irmDKIAQiXfftfLH+UnZtgyOC6LPv17R708LxUpaoUTANh0tP6oLv5
JSABgDwjlbdD9Z9IAfpwOXlbiy5SNyVj68KnZqOfdr0Fb8RVcZ1cLDL8l/EV5COV
40ZmE+Enx5DK9cL9+pTYqi2EPAq96UEZnWOWP9D9s8F2bxjBOAA=
=67iw
-----END PGP SIGNATURE-----

--dc+cDN39EJAMEtIO--

