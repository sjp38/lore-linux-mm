Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FFC1C3A5A3
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:14:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62D0820856
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:14:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kxL5f0dW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62D0820856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1702B6B0006; Tue, 27 Aug 2019 21:14:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 149C56B0008; Tue, 27 Aug 2019 21:14:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 010696B000A; Tue, 27 Aug 2019 21:14:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id D39DB6B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 21:14:44 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7F79E8418
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:14:44 +0000 (UTC)
X-FDA: 75870066888.24.bomb67_80a6ea6594e3a
X-HE-Tag: bomb67_80a6ea6594e3a
X-Filterd-Recvd-Size: 3729
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:14:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:Cc:From:References:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=hfSx8v0zhIV+bXC+CodQztxjQ/b6g4dcxtBZrzRlWPs=; b=kxL5f0dWo7sB0WNPrB0IaSLY7
	MbNT2c+q6KEjvIRj65dBT3HQu0J0qW2J+yuxyG93K/X1w6GQYhWFiPDwTrlwGDIUhnpoXDKMhvKNh
	G7keMO2VEKiqAmLzL1v0r3lUDWwvnxe3F/H2LTPH7MCTOE0WGt0F4b+sHbwkaLfLcoPSaA5Uvs6Sx
	X/7vpKszkDmVggCa7+U58gqc2KS2enuH4tRmyaZjeVU0ObU1qsqmO0gl5TQf1edJhcqJ0MnvSTvK7
	MreUZ+Ucmf+3ez2qvttBxfq8782KE01IEy+gsHiBcoqkRGj+kkaeVulwpjNrFKxEhZuo04pzKqX0u
	w4QUJsD/g==;
Received: from [2601:1c0:6200:6e8::4f71]
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i2mXh-0001yi-EV; Wed, 28 Aug 2019 01:14:33 +0000
Subject: Re: mmotm 2019-08-24-16-02 uploaded
 (drivers/tty/serial/fsl_linflexuart.c:)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 "open list:SERIAL DRIVERS" <linux-serial@vger.kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <20190824230323.REILuVBbY%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Cc: Fugang Duan <fugang.duan@nxp.com>
Message-ID: <b082b200-7298-6cd5-6981-44439bc2d788@infradead.org>
Date: Tue, 27 Aug 2019 18:14:32 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190824230323.REILuVBbY%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/24/19 4:03 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-08-24-16-02 has been uploaded to
>=20
>    http://www.ozlabs.org/~akpm/mmotm/
>=20
> mmotm-readme.txt says
>=20
> README for mm-of-the-moment:
>=20
> http://www.ozlabs.org/~akpm/mmotm/
>=20
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
>=20
> You will need quilt to apply these patches to the latest Linus release =
(5.x
> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated=
 in
> http://ozlabs.org/~akpm/mmotm/series
>=20
> The file broken-out.tar.gz contains two datestamp files: .DATE and
> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss=
,
> followed by the base kernel version against which this patch series is =
to
> be applied.
>=20
> This tree is partially included in linux-next.  To see which patches ar=
e
> included in linux-next, consult the `series' file.  Only the patches
> within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included i=
n
> linux-next.

on i386:
when CONFIG_PRINTK is not set/enabled:

../drivers/tty/serial/fsl_linflexuart.c: In function =E2=80=98linflex_ear=
lycon_putchar=E2=80=99:
../drivers/tty/serial/fsl_linflexuart.c:608:31: error: =E2=80=98CONFIG_LO=
G_BUF_SHIFT=E2=80=99 undeclared (first use in this function); did you mea=
n =E2=80=98CONFIG_DEBUG_SHIRQ=E2=80=99?
  if (earlycon_buf.len >=3D 1 << CONFIG_LOG_BUF_SHIFT)
                               ^~~~~~~~~~~~~~~~~~~~
                               CONFIG_DEBUG_SHIRQ


--=20
~Randy

