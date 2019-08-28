Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 143A2C3A5A3
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:28:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9F02214DA
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:28:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NL0QwD9+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9F02214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 696046B0006; Tue, 27 Aug 2019 21:28:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6475B6B0008; Tue, 27 Aug 2019 21:28:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 537C46B000A; Tue, 27 Aug 2019 21:28:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0164.hostedemail.com [216.40.44.164])
	by kanga.kvack.org (Postfix) with ESMTP id 334A66B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 21:28:06 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BD930824CA28
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:28:05 +0000 (UTC)
X-FDA: 75870100530.21.mist66_63bc29ac36648
X-HE-Tag: mist66_63bc29ac36648
X-Filterd-Recvd-Size: 3687
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:28:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SsIBUUgqWoBft4g1qjISTKId449C/sPPvMGvzOhucFA=; b=NL0QwD9+KL+vnxXxnHD22icys
	mAORzuHaSIFUSHIhL3+yR6+3Kw+Qw6J/6PoYN0NLBELIl+FOSjq3AKOVb+iL+oSavoNWl9TEY6MtG
	ER7D89Yy16NJQ0AGslo98M6jwxfxiSGSs7N2/iUCcAJuhq0XUj+Cql+pHW58ej07QMxahlx7gxTr3
	bZgEBi9/26cO2G+efQVHUSRUCfF2WAZ3RT2cIoL7eQvyTkU+ay4lxFe38y0ds4WEwvDUppyReQeiK
	2/B425Y0hB/FAL3qGJg25iXIW4jLLKzEd7qJOMUDbQ5Jbav0vEpQGjFjIXP+Tn6sROyOQ47FbLVNk
	zNEYwo2fg==;
Received: from [2601:1c0:6200:6e8::4f71]
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i2mkf-00068z-5y; Wed, 28 Aug 2019 01:27:57 +0000
Subject: Re: mmotm 2019-08-24-16-02 uploaded (intel_drv.h header check)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 intel-gfx <intel-gfx@lists.freedesktop.org>,
 dri-devel <dri-devel@lists.freedesktop.org>
References: <20190824230323.REILuVBbY%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <b08dbe92-8e10-aa3a-7f92-12b53ee5b368@infradead.org>
Date: Tue, 27 Aug 2019 18:27:56 -0700
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

on x86_64 or i386:

  CC      drivers/gpu/drm/i915/intel_drv.h.s
In file included from <command-line>:0:0:
./../drivers/gpu/drm/i915/intel_drv.h:402:24: error: field =E2=80=98force=
_audio=E2=80=99 has incomplete type
  enum hdmi_force_audio force_audio;
                        ^~~~~~~~~~~
./../drivers/gpu/drm/i915/intel_drv.h:1228:20: error: field =E2=80=98tc_t=
ype=E2=80=99 has incomplete type
  enum tc_port_type tc_type;
                    ^~~~~~~


--=20
~Randy

