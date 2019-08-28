Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.9 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34990C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 05:30:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF7122173E
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 05:30:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jRSPoAMd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF7122173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F2F76B0008; Wed, 28 Aug 2019 01:30:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A21A6B000C; Wed, 28 Aug 2019 01:30:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B7EB6B000D; Wed, 28 Aug 2019 01:30:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2DF6B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:30:47 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D7F4A180AD802
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 05:30:46 +0000 (UTC)
X-FDA: 75870712092.08.tin95_23dd185f96138
X-HE-Tag: tin95_23dd185f96138
X-Filterd-Recvd-Size: 4540
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 05:30:46 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id m3so756498pgv.13
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 22:30:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=qecDIkMeHBFjm/kMW1gsobuyMP+gtivx3tLy17j70fI=;
        b=jRSPoAMdEZqyMHgL4B0YmmMwy1VnO8QPUNCTSG7YqC93q88WjBS8hppPgCMqaLP/x/
         bjMqp5/ikaBz4qEyk7Kdb4V/jRuG0PdAR1Eb8qd4jV5LxhxtCD1fp6oX3etXZDVCCO80
         OvJL6+onURyXpTItyg2jJK2FjkorbCuD1sWItgz7vE4wd9GX7aKHp+YNs09MUOpqPSOs
         cU70ZRllPME73UPe2ISdMl0yUnanoPR5QnUb2YSyS3IXcTBMP0x1SYnHAg0XceqAvMOs
         Y1jSmX77POzPCBhagit4Bc/VbsqdHWGSgv7U9Wm1RbaYtmGJWxXO786gt6OCCnGr9ep0
         akdA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=qecDIkMeHBFjm/kMW1gsobuyMP+gtivx3tLy17j70fI=;
        b=mA+3sJITwkxp2/TP3kV6u13sZWRbEtq61YL4VB7kKsGQLCOpxXoukYdj3lRFELgVMl
         ouAihTR8RIQ+/x2MVWzn7Byo8Z8Fub0Q+hUtYFUHrz1xB6ZuO2SHCjnhvvBssBkb2HhR
         e0y/4gsgl5hkUm1kt5a9+xpF0rtn/SExm8wBu++gb0hZ2s58PzRLCmp7tW+JR9KiuOoE
         2XfjuBODDGxD5jOsy8ETnlyrwI3/3mQnFTywUk8SuKUVrr4VBUEwCk+sy1+ZNPjsW5ZR
         fDBloBpacbwGFhueFboVUF7ClpQsGa8kA7YxCDO6SCr4avDCGjFFv3j2NWv5Ah3DYDK/
         xcMA==
X-Gm-Message-State: APjAAAWlQLTJcfeHQPTxWB3z5jIrXYH/QE8tEQTPQy/ChBDela+sC1zD
	bTJPvT8B4SKXXNv7vp5siAw=
X-Google-Smtp-Source: APXvYqzs9qv8QyGAzL0ZrVFVOrYL3MkkQw8ssw8tigeK6949uy2jyvPhWTsxoNF16sIrw3nnfpLK6Q==
X-Received: by 2002:a62:7912:: with SMTP id u18mr2740540pfc.254.1566970245542;
        Tue, 27 Aug 2019 22:30:45 -0700 (PDT)
Received: from localhost ([39.7.47.251])
        by smtp.gmail.com with ESMTPSA id 4sm1212555pfn.118.2019.08.27.22.30.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 27 Aug 2019 22:30:44 -0700 (PDT)
Date: Wed, 28 Aug 2019 14:30:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	Linux Next Mailing List <linux-next@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>,
	Nitin Gupta <ngupta@vflare.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: linux-next: Tree for Aug 27 (mm/zsmalloc.c)
Message-ID: <20190828053041.GC526@jagdpanzerIV>
References: <20190827190526.6f27e763@canb.auug.org.au>
 <895d0324-3537-3d36-fa0f-5d61b733ef6e@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <895d0324-3537-3d36-fa0f-5d61b733ef6e@infradead.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/27/19 08:37), Randy Dunlap wrote:
> on x86_64:
>=20
> In file included from ../include/linux/mmzone.h:10:0,
>                  from ../include/linux/gfp.h:6,
>                  from ../include/linux/umh.h:4,
>                  from ../include/linux/kmod.h:9,
>                  from ../include/linux/module.h:13,
>                  from ../mm/zsmalloc.c:33:
> ../mm/zsmalloc.c: In function =E2=80=98zs_create_pool=E2=80=99:
> ../mm/zsmalloc.c:2416:27: error: =E2=80=98struct zs_pool=E2=80=99 has n=
o member named =E2=80=98migration_wait=E2=80=99
>   init_waitqueue_head(&pool->migration_wait);
>                            ^
> ../include/linux/wait.h:67:26: note: in definition of macro =E2=80=98in=
it_waitqueue_head=E2=80=99
>    __init_waitqueue_head((wq_head), #wq_head, &__key);  \
>                           ^~~~~~~

Thanks.

I believe akpm has a patch for that build error.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

--- a/mm/zsmalloc.c~mm-zsmallocc-fix-build-when-config_compaction=3Dn
+++ a/mm/zsmalloc.c
@@ -2412,7 +2412,9 @@ struct zs_pool *zs_create_pool(const cha
        if (!pool->name)
                goto err;

+#ifdef CONFIG_COMPACTION
        init_waitqueue_head(&pool->migration_wait);
+#endif

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

	-ss

