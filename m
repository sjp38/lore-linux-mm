Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C637C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 07:43:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C004F218B0
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 07:43:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sFQS50W9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C004F218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24BE68E0021; Thu,  7 Feb 2019 02:43:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FB688E0002; Thu,  7 Feb 2019 02:43:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 114188E0021; Thu,  7 Feb 2019 02:43:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8D568E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 02:43:14 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w185so8820692qka.9
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 23:43:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=hgWiPuQktGDPbFQrOQ3Zw6WnbDS/jHeyLQ4R4JqPa1k=;
        b=j/RhQq4samnrlM003E6LNzTbKDV4/ikMmWj6hu1yv3ZXgeRtU69OxPvWyxLUBN8oy5
         wzo4W95uItg9amvkfNm2VK8vvBrhwedKa0p0mo6GeudrTl8XFgbLIEbBLPlXiA3JF2EH
         tVw4MIuKB5rZxMRxv0dwDfP2SYT8kZpYMvJ32CBOIluV3yoMiZHKRGOhBajYt717q3ZT
         D/7bhoGRcpeIelhFCsj7oxlwvtlWSxYwzh2ebNNssJkqb9/OlYJiFHYaPo2TPVdoJK7F
         Nr/KWFQZcl4j+hwiL4hc//M25aqkixgPT0p88fTCdcwCnLZvT3w8qAD2ZQPbaAPsMxLb
         EFAA==
X-Gm-Message-State: AHQUAuZJJDFnxyq3aF0l9JKBtrImjLBcqYoXmmMUenxFlz2TMZ9KFeGm
	niXImO/U6O8dClTORbG5mnKaTb0gxzJcgKKnrz73r6jpcPnlj338GTDNoMXDllINsPamTz34h2E
	7lxxxx2JoqUpRf9+sHfDW+qEZNBuz06jqkvTV7G7l5Loxvuk4wQIqIA08kriBwPnYFUJDpZTpyR
	S0WHq1U7p78NjXYrUE0c4LwjKmmTf8eAcHB04E6ATGKbPECbOxly8qk3J9O8UI+UhooLtqCRDkg
	wmCSgRWWhY2GaMrFJNYqnT4rqe+lKFWuCT5eUuNXfw/4xHkKOmtoVgq95Uiq5lPS9cTxtVrTTyh
	ej1uPWd1Q+Rat1WPr75IKi1waf+PpbPyavlocnFgMipwIb/tqwkwjFtEMbmyp89ZMGpQpbSstMp
	r
X-Received: by 2002:a37:a0d4:: with SMTP id j203mr10874715qke.9.1549525394590;
        Wed, 06 Feb 2019 23:43:14 -0800 (PST)
X-Received: by 2002:a37:a0d4:: with SMTP id j203mr10874695qke.9.1549525393974;
        Wed, 06 Feb 2019 23:43:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549525393; cv=none;
        d=google.com; s=arc-20160816;
        b=LbgWqWZi/Q/UqHAejug0njlNRCFNOddWBU9P2se5ttdVz5noWhFMW88gkzGwgNujlt
         JLITgX/cIG0weefomK4b/aXQOc9y7/ZO4w+U1bc8vBd7qebLme5i/IhjJ82GetIgz/hN
         AhwN/WZP0UJ2JoOtDpGUXXCnVvTtmGi0zvFhvUlIcBHpXPzZh2zAvYIfiwr6Iu4KSuwT
         bDk2yRXzkJOnp6NTaZcblNPOyuFgKkexbs+roP5cIBeopaALhXCHn/v+ISuTqlhpY5w4
         1xZCN9LE/D4pnPYFXBCBEHK1DHByuOi2NfAmJFpmJFA+5AqdAD4ruUknMDkjo+H9CKh4
         /X2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hgWiPuQktGDPbFQrOQ3Zw6WnbDS/jHeyLQ4R4JqPa1k=;
        b=smPkxpXJyrP22nxz6X8xbqCjeKxDNhSWk5QqIwhXxBQJuNBJ6L7MQ8bIe5ByR/DUvq
         d2Xi5gkKUhkYg4fnPOzGOoUKbFUlGmghaIEk2vQzayLqGqNLbac3pYBK0ozFpKRwFXbi
         T0rdnB/mvoannKhA5xp2fuaCQ+TZQ74UuwqWx7k4DhPAs7TgjpFBt/I396EhTKXwgKBQ
         1UaMl4Ly1T9LeHpvuXl05wd1Vwih/6pv0CAEws/qxGREi/hJ0HzHwubMMR38zWew5ojX
         ytk91IJqIpQcOFOrkarPJB+yaurjWq+FSroS32mv6OUYyvZXYiolv/FeK0bdJRd/5afs
         Ly5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sFQS50W9;
       spf=pass (google.com: domain of bjorn.topel@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bjorn.topel@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r35sor18446062qtr.48.2019.02.06.23.43.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 23:43:13 -0800 (PST)
Received-SPF: pass (google.com: domain of bjorn.topel@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sFQS50W9;
       spf=pass (google.com: domain of bjorn.topel@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bjorn.topel@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=hgWiPuQktGDPbFQrOQ3Zw6WnbDS/jHeyLQ4R4JqPa1k=;
        b=sFQS50W9xOhD0g+DL/NQVoLqngbI0oniG4ARw3FONq4btMQmjVPCfS42/cOhgliKff
         mHNiWREzOlNAZQQfB6khK4OXLyIVNU1rGp1rC8pYQO2Ya0HHmKAgI8Eavkcfuy55ml52
         4olKvAZxp5sN4kexTIBg1uJWLSig2IxB4KSEnMqjYAT8HqAufCATorfSWA1Ao3SjSw3+
         43GvsJRzNyGZUiP9mOD8SxFKHP0lloRYV/lP3gCiNYwtpneDOFTPsilQvoHf8xTrr9jD
         yNI5rYE4CQQn8CXTriDBXZ/XFInKCk6BrP2/na8mpXw6X/5tobMJ4p8gBT8ORaXuevud
         g7Gw==
X-Google-Smtp-Source: AHgI3IbWQOMVE5pdb7AUDgZmR0M9ALEakMOW8WteZdZIB6Ntsh0TzahDpdKwo1h1zwuIehnKKjj/0e+1Mtl8buJTpho=
X-Received: by 2002:ac8:4453:: with SMTP id m19mr855654qtn.303.1549525393551;
 Wed, 06 Feb 2019 23:43:13 -0800 (PST)
MIME-Version: 1.0
References: <20190207053740.26915-1-dave@stgolabs.net> <20190207053740.26915-2-dave@stgolabs.net>
In-Reply-To: <20190207053740.26915-2-dave@stgolabs.net>
From: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>
Date: Thu, 7 Feb 2019 08:43:02 +0100
Message-ID: <CAJ+HfNg=Wikc_uY9W1QiVCONq3c1GyS44-xbrq-J4gqfth2kwQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] xsk: do not use mmap_sem
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>, "David S . Miller" <davem@davemloft.net>, 
	Bjorn Topel <bjorn.topel@intel.com>, Magnus Karlsson <magnus.karlsson@intel.com>, 
	Netdev <netdev@vger.kernel.org>, Davidlohr Bueso <dbueso@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Den tors 7 feb. 2019 kl 06:38 skrev Davidlohr Bueso <dave@stgolabs.net>:
>
> Holding mmap_sem exclusively for a gup() is an overkill.
> Lets replace the call for gup_fast() and let the mm take
> it if necessary.
>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Bjorn Topel <bjorn.topel@intel.com>
> Cc: Magnus Karlsson <magnus.karlsson@intel.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
>  net/xdp/xdp_umem.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> index 5ab236c5c9a5..25e1e76654a8 100644
> --- a/net/xdp/xdp_umem.c
> +++ b/net/xdp/xdp_umem.c
> @@ -265,10 +265,8 @@ static int xdp_umem_pin_pages(struct xdp_umem *umem)
>         if (!umem->pgs)
>                 return -ENOMEM;
>
> -       down_write(&current->mm->mmap_sem);
> -       npgs =3D get_user_pages(umem->address, umem->npgs,
> -                             gup_flags, &umem->pgs[0], NULL);
> -       up_write(&current->mm->mmap_sem);
> +       npgs =3D get_user_pages_fast(umem->address, umem->npgs,
> +                                  gup_flags, &umem->pgs[0]);
>

Thanks for the patch!

The lifetime of the pinning is similar to RDMA umem mapping, so isn't
gup_longterm preferred?


Bj=C3=B6rn

>         if (npgs !=3D umem->npgs) {
>                 if (npgs >=3D 0) {
> --
> 2.16.4
>

