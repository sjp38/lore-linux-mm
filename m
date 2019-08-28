Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ACBBC3A5A4
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 18:30:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDA822070B
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 18:30:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Li7H/9Kk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDA822070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2378D6B0005; Wed, 28 Aug 2019 14:30:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C1586B0008; Wed, 28 Aug 2019 14:30:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 089646B000C; Wed, 28 Aug 2019 14:30:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id D606B6B0005
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:30:49 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 79B29180AD802
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:30:49 +0000 (UTC)
X-FDA: 75872677818.01.prose26_71f841153d4a
X-HE-Tag: prose26_71f841153d4a
X-Filterd-Recvd-Size: 9141
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:30:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=z/GTsMOG+FQ14Ym0CrHcgUMZHK5aHnNQzVskveU9sFI=; b=Li7H/9KkJmMz6GCqvX5y9EHsF
	+rH6LaBMZx+HpuK0K0fVeaPwkqeEY1bHnK1uLkYcKLTbU5fvUYUQsZZVRc+w7EyOHGM+7Pm+aYDzj
	lv8IwQQJ50WqfOtBlSURlzaBUdhASj25YJQ7zxbj80H3Y2I5+6G5Myhod459e8T1FtpYJEAYBUZ5U
	GS0vt/SFZ6+KktBYOHTZq7pqeYCBVaA/GqnfcFnifKwk87MaB8bOhlJa1A8tXAUQLW7RlbDFLUIfX
	Pg9C8cBK6CtV6Nh7SlVywqSv8sPTuM2gqLq2NRYZZgfTIe/QlRJpUQFOXuz/Yhbeyndl61cinK2yQ
	ZQyStrNTA==;
Received: from [2601:1c0:6200:6e8::4f71]
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i32iN-0003wd-MP; Wed, 28 Aug 2019 18:30:39 +0000
Subject: Re: mmotm 2019-08-27-20-39 uploaded (sound/hda/intel-nhlt.c)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 moderated for non-subscribers <alsa-devel@alsa-project.org>,
 Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <274054ef-8611-2661-9e67-4aabae5a7728@infradead.org>
Date: Wed, 28 Aug 2019 11:30:38 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/27/19 8:40 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-08-27-20-39 has been uploaded to
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

(from linux-next tree, but problem found/seen in mmotm)

Sorry, I don't know who is responsible for this driver.

~~~~~~~~~~~~~~~~~~~~~~
on i386:

  CC      sound/hda/intel-nhlt.o
../sound/hda/intel-nhlt.c:14:25: error: redefinition of =E2=80=98intel_nh=
lt_init=E2=80=99
 struct nhlt_acpi_table *intel_nhlt_init(struct device *dev)
                         ^~~~~~~~~~~~~~~
In file included from ../sound/hda/intel-nhlt.c:5:0:
../include/sound/intel-nhlt.h:134:39: note: previous definition of =E2=80=
=98intel_nhlt_init=E2=80=99 was here
 static inline struct nhlt_acpi_table *intel_nhlt_init(struct device *dev=
)
                                       ^~~~~~~~~~~~~~~
../sound/hda/intel-nhlt.c: In function =E2=80=98intel_nhlt_init=E2=80=99:
../sound/hda/intel-nhlt.c:39:14: error: dereferencing pointer to incomple=
te type =E2=80=98struct nhlt_resource_desc=E2=80=99
  if (nhlt_ptr->length)
              ^~
../sound/hda/intel-nhlt.c:41:4: error: implicit declaration of function =E2=
=80=98memremap=E2=80=99; did you mean =E2=80=98ioremap=E2=80=99? [-Werror=
=3Dimplicit-function-declaration]
    memremap(nhlt_ptr->min_addr, nhlt_ptr->length,
    ^~~~~~~~
    ioremap
../sound/hda/intel-nhlt.c:42:6: error: =E2=80=98MEMREMAP_WB=E2=80=99 unde=
clared (first use in this function)
      MEMREMAP_WB);
      ^~~~~~~~~~~
../sound/hda/intel-nhlt.c:42:6: note: each undeclared identifier is repor=
ted only once for each function it appears in
../sound/hda/intel-nhlt.c:45:25: error: dereferencing pointer to incomple=
te type =E2=80=98struct nhlt_acpi_table=E2=80=99
      (strncmp(nhlt_table->header.signature,
                         ^~
../sound/hda/intel-nhlt.c:48:3: error: implicit declaration of function =E2=
=80=98memunmap=E2=80=99; did you mean =E2=80=98vunmap=E2=80=99? [-Werror=3D=
implicit-function-declaration]
   memunmap(nhlt_table);
   ^~~~~~~~
   vunmap
../sound/hda/intel-nhlt.c: At top level:
../sound/hda/intel-nhlt.c:56:6: error: redefinition of =E2=80=98intel_nhl=
t_free=E2=80=99
 void intel_nhlt_free(struct nhlt_acpi_table *nhlt)
      ^~~~~~~~~~~~~~~
In file included from ../sound/hda/intel-nhlt.c:5:0:
../include/sound/intel-nhlt.h:139:20: note: previous definition of =E2=80=
=98intel_nhlt_free=E2=80=99 was here
 static inline void intel_nhlt_free(struct nhlt_acpi_table *addr)
                    ^~~~~~~~~~~~~~~
../sound/hda/intel-nhlt.c:62:5: error: redefinition of =E2=80=98intel_nhl=
t_get_dmic_geo=E2=80=99
 int intel_nhlt_get_dmic_geo(struct device *dev, struct nhlt_acpi_table *=
nhlt)
     ^~~~~~~~~~~~~~~~~~~~~~~
In file included from ../sound/hda/intel-nhlt.c:5:0:
../include/sound/intel-nhlt.h:143:19: note: previous definition of =E2=80=
=98intel_nhlt_get_dmic_geo=E2=80=99 was here
 static inline int intel_nhlt_get_dmic_geo(struct device *dev,
                   ^~~~~~~~~~~~~~~~~~~~~~~
../sound/hda/intel-nhlt.c: In function =E2=80=98intel_nhlt_get_dmic_geo=E2=
=80=99:
../sound/hda/intel-nhlt.c:76:11: error: dereferencing pointer to incomple=
te type =E2=80=98struct nhlt_endpoint=E2=80=99
   if (epnt->linktype =3D=3D NHLT_LINK_DMIC) {
           ^~
../sound/hda/intel-nhlt.c:76:25: error: =E2=80=98NHLT_LINK_DMIC=E2=80=99 =
undeclared (first use in this function)
   if (epnt->linktype =3D=3D NHLT_LINK_DMIC) {
                         ^~~~~~~~~~~~~~
../sound/hda/intel-nhlt.c:79:15: error: dereferencing pointer to incomple=
te type =E2=80=98struct nhlt_dmic_array_config=E2=80=99
    switch (cfg->array_type) {
               ^~
../sound/hda/intel-nhlt.c:80:9: error: =E2=80=98NHLT_MIC_ARRAY_2CH_SMALL=E2=
=80=99 undeclared (first use in this function)
    case NHLT_MIC_ARRAY_2CH_SMALL:
         ^~~~~~~~~~~~~~~~~~~~~~~~
../sound/hda/intel-nhlt.c:81:9: error: =E2=80=98NHLT_MIC_ARRAY_2CH_BIG=E2=
=80=99 undeclared (first use in this function); did you mean =E2=80=98NHL=
T_MIC_ARRAY_2CH_SMALL=E2=80=99?
    case NHLT_MIC_ARRAY_2CH_BIG:
         ^~~~~~~~~~~~~~~~~~~~~~
         NHLT_MIC_ARRAY_2CH_SMALL
../sound/hda/intel-nhlt.c:82:16: error: =E2=80=98MIC_ARRAY_2CH=E2=80=99 u=
ndeclared (first use in this function); did you mean =E2=80=98NHLT_MIC_AR=
RAY_2CH_BIG=E2=80=99?
     dmic_geo =3D MIC_ARRAY_2CH;
                ^~~~~~~~~~~~~
                NHLT_MIC_ARRAY_2CH_BIG
../sound/hda/intel-nhlt.c:85:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_1ST_GE=
OM=E2=80=99 undeclared (first use in this function); did you mean =E2=80=98=
NHLT_MIC_ARRAY_2CH_BIG=E2=80=99?
    case NHLT_MIC_ARRAY_4CH_1ST_GEOM:
         ^~~~~~~~~~~~~~~~~~~~~~~~~~~
         NHLT_MIC_ARRAY_2CH_BIG
../sound/hda/intel-nhlt.c:86:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_L_SHAP=
ED=E2=80=99 undeclared (first use in this function); did you mean =E2=80=98=
NHLT_MIC_ARRAY_4CH_1ST_GEOM=E2=80=99?
    case NHLT_MIC_ARRAY_4CH_L_SHAPED:
         ^~~~~~~~~~~~~~~~~~~~~~~~~~~
         NHLT_MIC_ARRAY_4CH_1ST_GEOM
  AR      sound/i2c/other/built-in.a
../sound/hda/intel-nhlt.c:87:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_2ND_GE=
OM=E2=80=99 undeclared (first use in this function); did you mean =E2=80=98=
NHLT_MIC_ARRAY_4CH_1ST_GEOM=E2=80=99?
    case NHLT_MIC_ARRAY_4CH_2ND_GEOM:
         ^~~~~~~~~~~~~~~~~~~~~~~~~~~
         NHLT_MIC_ARRAY_4CH_1ST_GEOM
../sound/hda/intel-nhlt.c:88:16: error: =E2=80=98MIC_ARRAY_4CH=E2=80=99 u=
ndeclared (first use in this function); did you mean =E2=80=98MIC_ARRAY_2=
CH=E2=80=99?
     dmic_geo =3D MIC_ARRAY_4CH;
                ^~~~~~~~~~~~~
                MIC_ARRAY_2CH
  AR      sound/i2c/built-in.a
  CC      drivers/bluetooth/btmtksdio.o
../sound/hda/intel-nhlt.c:90:9: error: =E2=80=98NHLT_MIC_ARRAY_VENDOR_DEF=
INED=E2=80=99 undeclared (first use in this function); did you mean =E2=80=
=98NHLT_MIC_ARRAY_4CH_L_SHAPED=E2=80=99?
    case NHLT_MIC_ARRAY_VENDOR_DEFINED:
         ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         NHLT_MIC_ARRAY_4CH_L_SHAPED
../sound/hda/intel-nhlt.c:92:26: error: dereferencing pointer to incomple=
te type =E2=80=98struct nhlt_vendor_dmic_array_config=E2=80=99
     dmic_geo =3D cfg_vendor->nb_mics;
                          ^~
../sound/hda/intel-nhlt.c: At top level:
../sound/hda/intel-nhlt.c:106:16: error: expected declaration specifiers =
or =E2=80=98...=E2=80=99 before string constant
 MODULE_LICENSE("GPL v2");
                ^~~~~~~~
../sound/hda/intel-nhlt.c:107:20: error: expected declaration specifiers =
or =E2=80=98...=E2=80=99 before string constant
 MODULE_DESCRIPTION("Intel NHLT driver");
                    ^~~~~~~~~~~~~~~~~~~
cc1: some warnings being treated as errors
make[3]: *** [../scripts/Makefile.build:266: sound/hda/intel-nhlt.o] Erro=
r 1



--=20
~Randy

