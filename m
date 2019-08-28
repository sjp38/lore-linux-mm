Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E2E0C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 19:28:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29C01208C2
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 19:28:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29C01208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ADBE6B0006; Wed, 28 Aug 2019 15:28:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95F1A6B000C; Wed, 28 Aug 2019 15:28:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84D106B000D; Wed, 28 Aug 2019 15:28:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0236.hostedemail.com [216.40.44.236])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7356B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 15:28:05 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id EF0C1A2BA
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 19:28:04 +0000 (UTC)
X-FDA: 75872822088.30.flesh93_4671e88be1334
X-HE-Tag: flesh93_4671e88be1334
X-Filterd-Recvd-Size: 10664
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 19:28:03 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Aug 2019 12:28:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,442,1559545200"; 
   d="scan'208";a="380519016"
Received: from amathu3-mobl1.amr.corp.intel.com (HELO [10.254.179.245]) ([10.254.179.245])
  by fmsmga005.fm.intel.com with ESMTP; 28 Aug 2019 12:28:01 -0700
Subject: Re: mmotm 2019-08-27-20-39 uploaded (sound/hda/intel-nhlt.c)
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org,
 broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au,
 moderated for non-subscribers <alsa-devel@alsa-project.org>
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
 <274054ef-8611-2661-9e67-4aabae5a7728@infradead.org>
From: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
Message-ID: <5ac8a7a7-a9b4-89a5-e0a6-7c97ec1fabc6@linux.intel.com>
Date: Wed, 28 Aug 2019 14:28:01 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <274054ef-8611-2661-9e67-4aabae5a7728@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/28/19 1:30 PM, Randy Dunlap wrote:
> On 8/27/19 8:40 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2019-08-27-20-39 has been uploaded to
>>
>>     http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
>>
>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefull=
y
>> more than once a week.
>>
>> You will need quilt to apply these patches to the latest Linus release=
 (5.x
>> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicate=
d in
>> http://ozlabs.org/~akpm/mmotm/series
>>
>> The file broken-out.tar.gz contains two datestamp files: .DATE and
>> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-s=
s,
>> followed by the base kernel version against which this patch series is=
 to
>> be applied.
>=20
> (from linux-next tree, but problem found/seen in mmotm)
>=20
> Sorry, I don't know who is responsible for this driver.

That would be me.

I just checked with Mark Brown's for-next tree=20
8aceffa09b4b9867153bfe0ff6f40517240cee12
and things are fine in i386 mode, see below.

next-20190828 also works fine for me in i386 mode.

if you can point me to a tree and configuration that don't work I'll=20
look into this, I'd need more info to progress.

make ARCH=3Di386
   Using /data/pbossart/ktest/broonie-next as source for kernel
   GEN     Makefile
   CALL    /data/pbossart/ktest/broonie-next/scripts/checksyscalls.sh
   CALL    /data/pbossart/ktest/broonie-next/scripts/atomic/check-atomics=
.sh
   CHK     include/generated/compile.h
   CC [M]  sound/hda/ext/hdac_ext_bus.o
   CC [M]  sound/hda/ext/hdac_ext_controller.o
   CC [M]  sound/hda/ext/hdac_ext_stream.o
   LD [M]  sound/hda/ext/snd-hda-ext-core.o
   CC [M]  sound/hda/hda_bus_type.o
   CC [M]  sound/hda/hdac_bus.o
   CC [M]  sound/hda/hdac_device.o
   CC [M]  sound/hda/hdac_sysfs.o
   CC [M]  sound/hda/hdac_regmap.o
   CC [M]  sound/hda/hdac_controller.o
   CC [M]  sound/hda/hdac_stream.o
   CC [M]  sound/hda/array.o
   CC [M]  sound/hda/hdmi_chmap.o
   CC [M]  sound/hda/trace.o
   CC [M]  sound/hda/hdac_component.o
   CC [M]  sound/hda/hdac_i915.o
   LD [M]  sound/hda/snd-hda-core.o
   CC [M]  sound/hda/intel-nhlt.o
   LD [M]  sound/hda/snd-intel-nhlt.o
Kernel: arch/x86/boot/bzImage is ready  (#18)
   Building modules, stage 2.
   MODPOST 156 modules
   CC      sound/hda/ext/snd-hda-ext-core.mod.o
   LD [M]  sound/hda/ext/snd-hda-ext-core.ko
   CC      sound/hda/snd-hda-core.mod.o
   LD [M]  sound/hda/snd-hda-core.ko
   CC      sound/hda/snd-intel-nhlt.mod.o
   LD [M]  sound/hda/snd-intel-nhlt.ko


>=20
> ~~~~~~~~~~~~~~~~~~~~~~
> on i386:
>=20
>    CC      sound/hda/intel-nhlt.o
> ../sound/hda/intel-nhlt.c:14:25: error: redefinition of =E2=80=98intel_=
nhlt_init=E2=80=99
>   struct nhlt_acpi_table *intel_nhlt_init(struct device *dev)
>                           ^~~~~~~~~~~~~~~
> In file included from ../sound/hda/intel-nhlt.c:5:0:
> ../include/sound/intel-nhlt.h:134:39: note: previous definition of =E2=80=
=98intel_nhlt_init=E2=80=99 was here
>   static inline struct nhlt_acpi_table *intel_nhlt_init(struct device *=
dev)
>                                         ^~~~~~~~~~~~~~~
> ../sound/hda/intel-nhlt.c: In function =E2=80=98intel_nhlt_init=E2=80=99=
:
> ../sound/hda/intel-nhlt.c:39:14: error: dereferencing pointer to incomp=
lete type =E2=80=98struct nhlt_resource_desc=E2=80=99
>    if (nhlt_ptr->length)
>                ^~
> ../sound/hda/intel-nhlt.c:41:4: error: implicit declaration of function=
 =E2=80=98memremap=E2=80=99; did you mean =E2=80=98ioremap=E2=80=99? [-We=
rror=3Dimplicit-function-declaration]
>      memremap(nhlt_ptr->min_addr, nhlt_ptr->length,
>      ^~~~~~~~
>      ioremap
> ../sound/hda/intel-nhlt.c:42:6: error: =E2=80=98MEMREMAP_WB=E2=80=99 un=
declared (first use in this function)
>        MEMREMAP_WB);
>        ^~~~~~~~~~~
> ../sound/hda/intel-nhlt.c:42:6: note: each undeclared identifier is rep=
orted only once for each function it appears in
> ../sound/hda/intel-nhlt.c:45:25: error: dereferencing pointer to incomp=
lete type =E2=80=98struct nhlt_acpi_table=E2=80=99
>        (strncmp(nhlt_table->header.signature,
>                           ^~
> ../sound/hda/intel-nhlt.c:48:3: error: implicit declaration of function=
 =E2=80=98memunmap=E2=80=99; did you mean =E2=80=98vunmap=E2=80=99? [-Wer=
ror=3Dimplicit-function-declaration]
>     memunmap(nhlt_table);
>     ^~~~~~~~
>     vunmap
> ../sound/hda/intel-nhlt.c: At top level:
> ../sound/hda/intel-nhlt.c:56:6: error: redefinition of =E2=80=98intel_n=
hlt_free=E2=80=99
>   void intel_nhlt_free(struct nhlt_acpi_table *nhlt)
>        ^~~~~~~~~~~~~~~
> In file included from ../sound/hda/intel-nhlt.c:5:0:
> ../include/sound/intel-nhlt.h:139:20: note: previous definition of =E2=80=
=98intel_nhlt_free=E2=80=99 was here
>   static inline void intel_nhlt_free(struct nhlt_acpi_table *addr)
>                      ^~~~~~~~~~~~~~~
> ../sound/hda/intel-nhlt.c:62:5: error: redefinition of =E2=80=98intel_n=
hlt_get_dmic_geo=E2=80=99
>   int intel_nhlt_get_dmic_geo(struct device *dev, struct nhlt_acpi_tabl=
e *nhlt)
>       ^~~~~~~~~~~~~~~~~~~~~~~
> In file included from ../sound/hda/intel-nhlt.c:5:0:
> ../include/sound/intel-nhlt.h:143:19: note: previous definition of =E2=80=
=98intel_nhlt_get_dmic_geo=E2=80=99 was here
>   static inline int intel_nhlt_get_dmic_geo(struct device *dev,
>                     ^~~~~~~~~~~~~~~~~~~~~~~
> ../sound/hda/intel-nhlt.c: In function =E2=80=98intel_nhlt_get_dmic_geo=
=E2=80=99:
> ../sound/hda/intel-nhlt.c:76:11: error: dereferencing pointer to incomp=
lete type =E2=80=98struct nhlt_endpoint=E2=80=99
>     if (epnt->linktype =3D=3D NHLT_LINK_DMIC) {
>             ^~
> ../sound/hda/intel-nhlt.c:76:25: error: =E2=80=98NHLT_LINK_DMIC=E2=80=99=
 undeclared (first use in this function)
>     if (epnt->linktype =3D=3D NHLT_LINK_DMIC) {
>                           ^~~~~~~~~~~~~~
> ../sound/hda/intel-nhlt.c:79:15: error: dereferencing pointer to incomp=
lete type =E2=80=98struct nhlt_dmic_array_config=E2=80=99
>      switch (cfg->array_type) {
>                 ^~
> ../sound/hda/intel-nhlt.c:80:9: error: =E2=80=98NHLT_MIC_ARRAY_2CH_SMAL=
L=E2=80=99 undeclared (first use in this function)
>      case NHLT_MIC_ARRAY_2CH_SMALL:
>           ^~~~~~~~~~~~~~~~~~~~~~~~
> ../sound/hda/intel-nhlt.c:81:9: error: =E2=80=98NHLT_MIC_ARRAY_2CH_BIG=E2=
=80=99 undeclared (first use in this function); did you mean =E2=80=98NHL=
T_MIC_ARRAY_2CH_SMALL=E2=80=99?
>      case NHLT_MIC_ARRAY_2CH_BIG:
>           ^~~~~~~~~~~~~~~~~~~~~~
>           NHLT_MIC_ARRAY_2CH_SMALL
> ../sound/hda/intel-nhlt.c:82:16: error: =E2=80=98MIC_ARRAY_2CH=E2=80=99=
 undeclared (first use in this function); did you mean =E2=80=98NHLT_MIC_=
ARRAY_2CH_BIG=E2=80=99?
>       dmic_geo =3D MIC_ARRAY_2CH;
>                  ^~~~~~~~~~~~~
>                  NHLT_MIC_ARRAY_2CH_BIG
> ../sound/hda/intel-nhlt.c:85:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_1ST_=
GEOM=E2=80=99 undeclared (first use in this function); did you mean =E2=80=
=98NHLT_MIC_ARRAY_2CH_BIG=E2=80=99?
>      case NHLT_MIC_ARRAY_4CH_1ST_GEOM:
>           ^~~~~~~~~~~~~~~~~~~~~~~~~~~
>           NHLT_MIC_ARRAY_2CH_BIG
> ../sound/hda/intel-nhlt.c:86:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_L_SH=
APED=E2=80=99 undeclared (first use in this function); did you mean =E2=80=
=98NHLT_MIC_ARRAY_4CH_1ST_GEOM=E2=80=99?
>      case NHLT_MIC_ARRAY_4CH_L_SHAPED:
>           ^~~~~~~~~~~~~~~~~~~~~~~~~~~
>           NHLT_MIC_ARRAY_4CH_1ST_GEOM
>    AR      sound/i2c/other/built-in.a
> ../sound/hda/intel-nhlt.c:87:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_2ND_=
GEOM=E2=80=99 undeclared (first use in this function); did you mean =E2=80=
=98NHLT_MIC_ARRAY_4CH_1ST_GEOM=E2=80=99?
>      case NHLT_MIC_ARRAY_4CH_2ND_GEOM:
>           ^~~~~~~~~~~~~~~~~~~~~~~~~~~
>           NHLT_MIC_ARRAY_4CH_1ST_GEOM
> ../sound/hda/intel-nhlt.c:88:16: error: =E2=80=98MIC_ARRAY_4CH=E2=80=99=
 undeclared (first use in this function); did you mean =E2=80=98MIC_ARRAY=
_2CH=E2=80=99?
>       dmic_geo =3D MIC_ARRAY_4CH;
>                  ^~~~~~~~~~~~~
>                  MIC_ARRAY_2CH
>    AR      sound/i2c/built-in.a
>    CC      drivers/bluetooth/btmtksdio.o
> ../sound/hda/intel-nhlt.c:90:9: error: =E2=80=98NHLT_MIC_ARRAY_VENDOR_D=
EFINED=E2=80=99 undeclared (first use in this function); did you mean =E2=
=80=98NHLT_MIC_ARRAY_4CH_L_SHAPED=E2=80=99?
>      case NHLT_MIC_ARRAY_VENDOR_DEFINED:
>           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>           NHLT_MIC_ARRAY_4CH_L_SHAPED
> ../sound/hda/intel-nhlt.c:92:26: error: dereferencing pointer to incomp=
lete type =E2=80=98struct nhlt_vendor_dmic_array_config=E2=80=99
>       dmic_geo =3D cfg_vendor->nb_mics;
>                            ^~
> ../sound/hda/intel-nhlt.c: At top level:
> ../sound/hda/intel-nhlt.c:106:16: error: expected declaration specifier=
s or =E2=80=98...=E2=80=99 before string constant
>   MODULE_LICENSE("GPL v2");
>                  ^~~~~~~~
> ../sound/hda/intel-nhlt.c:107:20: error: expected declaration specifier=
s or =E2=80=98...=E2=80=99 before string constant
>   MODULE_DESCRIPTION("Intel NHLT driver");
>                      ^~~~~~~~~~~~~~~~~~~
> cc1: some warnings being treated as errors
> make[3]: *** [../scripts/Makefile.build:266: sound/hda/intel-nhlt.o] Er=
ror 1
>=20
>=20
>=20

