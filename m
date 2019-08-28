Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A808DC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 22:20:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D7EA233A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 22:20:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D7EA233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3D6D6B0006; Wed, 28 Aug 2019 18:20:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EEEE6B0008; Wed, 28 Aug 2019 18:20:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 903916B000D; Wed, 28 Aug 2019 18:20:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1676B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:20:50 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0B93387F2
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 22:20:50 +0000 (UTC)
X-FDA: 75873257460.28.snow00_7b92bb72ccb43
X-HE-Tag: snow00_7b92bb72ccb43
X-Filterd-Recvd-Size: 11282
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 22:20:48 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Aug 2019 15:20:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,442,1559545200"; 
   d="scan'208";a="380561193"
Received: from amathu3-mobl1.amr.corp.intel.com (HELO [10.254.179.245]) ([10.254.179.245])
  by fmsmga005.fm.intel.com with ESMTP; 28 Aug 2019 15:20:46 -0700
Subject: Re: mmotm 2019-08-27-20-39 uploaded (sound/hda/intel-nhlt.c)
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org,
 broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au,
 moderated for non-subscribers <alsa-devel@alsa-project.org>
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
 <274054ef-8611-2661-9e67-4aabae5a7728@infradead.org>
 <5ac8a7a7-a9b4-89a5-e0a6-7c97ec1fabc6@linux.intel.com>
 <98ada795-4700-7fcc-6d14-fcc1ab25d509@infradead.org>
From: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
Message-ID: <f0a62b08-cba9-d944-5792-8eac0ea39df1@linux.intel.com>
Date: Wed, 28 Aug 2019 17:20:46 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <98ada795-4700-7fcc-6d14-fcc1ab25d509@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/28/19 4:06 PM, Randy Dunlap wrote:
> On 8/28/19 12:28 PM, Pierre-Louis Bossart wrote:
>>
>>
>> On 8/28/19 1:30 PM, Randy Dunlap wrote:
>=20
>>>
>>> (from linux-next tree, but problem found/seen in mmotm)
>>>
>>> Sorry, I don't know who is responsible for this driver.
>>
>> That would be me.
>>
>> I just checked with Mark Brown's for-next tree 8aceffa09b4b9867153bfe0=
ff6f40517240cee12
>> and things are fine in i386 mode, see below.
>>
>> next-20190828 also works fine for me in i386 mode.
>>
>> if you can point me to a tree and configuration that don't work I'll l=
ook into this, I'd need more info to progress.
>=20
> Please try the attached randconfig file.
>=20
> Thanks for looking.

Ack, I see some errors as well with this config. Likely a missing=20
dependency somewhere, working on this now.

>=20
>> make ARCH=3Di386
>>  =C2=A0 Using /data/pbossart/ktest/broonie-next as source for kernel
>>  =C2=A0 GEN=C2=A0=C2=A0=C2=A0=C2=A0 Makefile
>>  =C2=A0 CALL=C2=A0=C2=A0=C2=A0 /data/pbossart/ktest/broonie-next/scrip=
ts/checksyscalls.sh
>>  =C2=A0 CALL=C2=A0=C2=A0=C2=A0 /data/pbossart/ktest/broonie-next/scrip=
ts/atomic/check-atomics.sh
>>  =C2=A0 CHK=C2=A0=C2=A0=C2=A0=C2=A0 include/generated/compile.h
>>  =C2=A0 CC [M]=C2=A0 sound/hda/ext/hdac_ext_bus.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/ext/hdac_ext_controller.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/ext/hdac_ext_stream.o
>>  =C2=A0 LD [M]=C2=A0 sound/hda/ext/snd-hda-ext-core.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hda_bus_type.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdac_bus.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdac_device.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdac_sysfs.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdac_regmap.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdac_controller.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdac_stream.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/array.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdmi_chmap.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/trace.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdac_component.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/hdac_i915.o
>>  =C2=A0 LD [M]=C2=A0 sound/hda/snd-hda-core.o
>>  =C2=A0 CC [M]=C2=A0 sound/hda/intel-nhlt.o
>>  =C2=A0 LD [M]=C2=A0 sound/hda/snd-intel-nhlt.o
>> Kernel: arch/x86/boot/bzImage is ready=C2=A0 (#18)
>>  =C2=A0 Building modules, stage 2.
>>  =C2=A0 MODPOST 156 modules
>>  =C2=A0 CC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 sound/hda/ext/snd-hda-ext-cor=
e.mod.o
>>  =C2=A0 LD [M]=C2=A0 sound/hda/ext/snd-hda-ext-core.ko
>>  =C2=A0 CC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 sound/hda/snd-hda-core.mod.o
>>  =C2=A0 LD [M]=C2=A0 sound/hda/snd-hda-core.ko
>>  =C2=A0 CC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 sound/hda/snd-intel-nhlt.mod.=
o
>>  =C2=A0 LD [M]=C2=A0 sound/hda/snd-intel-nhlt.ko
>>
>>
>>>
>>> ~~~~~~~~~~~~~~~~~~~~~~
>>> on i386:
>>>
>>>  =C2=A0=C2=A0 CC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 sound/hda/intel-nhlt.o
>>> ../sound/hda/intel-nhlt.c:14:25: error: redefinition of =E2=80=98inte=
l_nhlt_init=E2=80=99
>>>  =C2=A0 struct nhlt_acpi_table *intel_nhlt_init(struct device *dev)
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 ^~~~~~~~~~~~~~~
>>> In file included from ../sound/hda/intel-nhlt.c:5:0:
>>> ../include/sound/intel-nhlt.h:134:39: note: previous definition of =E2=
=80=98intel_nhlt_init=E2=80=99 was here
>>>  =C2=A0 static inline struct nhlt_acpi_table *intel_nhlt_init(struct =
device *dev)
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~~~
>>> ../sound/hda/intel-nhlt.c: In function =E2=80=98intel_nhlt_init=E2=80=
=99:
>>> ../sound/hda/intel-nhlt.c:39:14: error: dereferencing pointer to inco=
mplete type =E2=80=98struct nhlt_resource_desc=E2=80=99
>>>  =C2=A0=C2=A0 if (nhlt_ptr->length)
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 ^~
>>> ../sound/hda/intel-nhlt.c:41:4: error: implicit declaration of functi=
on =E2=80=98memremap=E2=80=99; did you mean =E2=80=98ioremap=E2=80=99? [-=
Werror=3Dimplicit-function-declaration]
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 memremap(nhlt_ptr->min_addr, nhlt_ptr->leng=
th,
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 ioremap
>>> ../sound/hda/intel-nhlt.c:42:6: error: =E2=80=98MEMREMAP_WB=E2=80=99 =
undeclared (first use in this function)
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 MEMREMAP_WB);
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~
>>> ../sound/hda/intel-nhlt.c:42:6: note: each undeclared identifier is r=
eported only once for each function it appears in
>>> ../sound/hda/intel-nhlt.c:45:25: error: dereferencing pointer to inco=
mplete type =E2=80=98struct nhlt_acpi_table=E2=80=99
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 (strncmp(nhlt_table->header.sig=
nature,
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 ^~
>>> ../sound/hda/intel-nhlt.c:48:3: error: implicit declaration of functi=
on =E2=80=98memunmap=E2=80=99; did you mean =E2=80=98vunmap=E2=80=99? [-W=
error=3Dimplicit-function-declaration]
>>>  =C2=A0=C2=A0=C2=A0 memunmap(nhlt_table);
>>>  =C2=A0=C2=A0=C2=A0 ^~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0 vunmap
>>> ../sound/hda/intel-nhlt.c: At top level:
>>> ../sound/hda/intel-nhlt.c:56:6: error: redefinition of =E2=80=98intel=
_nhlt_free=E2=80=99
>>>  =C2=A0 void intel_nhlt_free(struct nhlt_acpi_table *nhlt)
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~~~
>>> In file included from ../sound/hda/intel-nhlt.c:5:0:
>>> ../include/sound/intel-nhlt.h:139:20: note: previous definition of =E2=
=80=98intel_nhlt_free=E2=80=99 was here
>>>  =C2=A0 static inline void intel_nhlt_free(struct nhlt_acpi_table *ad=
dr)
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~~~
>>> ../sound/hda/intel-nhlt.c:62:5: error: redefinition of =E2=80=98intel=
_nhlt_get_dmic_geo=E2=80=99
>>>  =C2=A0 int intel_nhlt_get_dmic_geo(struct device *dev, struct nhlt_a=
cpi_table *nhlt)
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~~~~~~~~~~~
>>> In file included from ../sound/hda/intel-nhlt.c:5:0:
>>> ../include/sound/intel-nhlt.h:143:19: note: previous definition of =E2=
=80=98intel_nhlt_get_dmic_geo=E2=80=99 was here
>>>  =C2=A0 static inline int intel_nhlt_get_dmic_geo(struct device *dev,
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~~~~~~~~~~~
>>> ../sound/hda/intel-nhlt.c: In function =E2=80=98intel_nhlt_get_dmic_g=
eo=E2=80=99:
>>> ../sound/hda/intel-nhlt.c:76:11: error: dereferencing pointer to inco=
mplete type =E2=80=98struct nhlt_endpoint=E2=80=99
>>>  =C2=A0=C2=A0=C2=A0 if (epnt->linktype =3D=3D NHLT_LINK_DMIC) {
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^=
~
>>> ../sound/hda/intel-nhlt.c:76:25: error: =E2=80=98NHLT_LINK_DMIC=E2=80=
=99 undeclared (first use in this function)
>>>  =C2=A0=C2=A0=C2=A0 if (epnt->linktype =3D=3D NHLT_LINK_DMIC) {
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 ^~~~~~~~~~~~~~
>>> ../sound/hda/intel-nhlt.c:79:15: error: dereferencing pointer to inco=
mplete type =E2=80=98struct nhlt_dmic_array_config=E2=80=99
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 switch (cfg->array_type) {
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 ^~
>>> ../sound/hda/intel-nhlt.c:80:9: error: =E2=80=98NHLT_MIC_ARRAY_2CH_SM=
ALL=E2=80=99 undeclared (first use in this function)
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 case NHLT_MIC_ARRAY_2CH_SMALL:
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~=
~~~~~~~~~~~
>>> ../sound/hda/intel-nhlt.c:81:9: error: =E2=80=98NHLT_MIC_ARRAY_2CH_BI=
G=E2=80=99 undeclared (first use in this function); did you mean =E2=80=98=
NHLT_MIC_ARRAY_2CH_SMALL=E2=80=99?
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 case NHLT_MIC_ARRAY_2CH_BIG:
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~=
~~~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 NHLT_MIC_ARRA=
Y_2CH_SMALL
>>> ../sound/hda/intel-nhlt.c:82:16: error: =E2=80=98MIC_ARRAY_2CH=E2=80=99=
 undeclared (first use in this function); did you mean =E2=80=98NHLT_MIC_=
ARRAY_2CH_BIG=E2=80=99?
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 dmic_geo =3D MIC_ARRAY_2CH;
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 NHLT_MIC_ARRAY_2CH_BIG
>>> ../sound/hda/intel-nhlt.c:85:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_1S=
T_GEOM=E2=80=99 undeclared (first use in this function); did you mean =E2=
=80=98NHLT_MIC_ARRAY_2CH_BIG=E2=80=99?
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 case NHLT_MIC_ARRAY_4CH_1ST_GEOM:
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~=
~~~~~~~~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 NHLT_MIC_ARRA=
Y_2CH_BIG
>>> ../sound/hda/intel-nhlt.c:86:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_L_=
SHAPED=E2=80=99 undeclared (first use in this function); did you mean =E2=
=80=98NHLT_MIC_ARRAY_4CH_1ST_GEOM=E2=80=99?
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 case NHLT_MIC_ARRAY_4CH_L_SHAPED:
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~=
~~~~~~~~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 NHLT_MIC_ARRA=
Y_4CH_1ST_GEOM
>>>  =C2=A0=C2=A0 AR=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 sound/i2c/other/built-=
in.a
>>> ../sound/hda/intel-nhlt.c:87:9: error: =E2=80=98NHLT_MIC_ARRAY_4CH_2N=
D_GEOM=E2=80=99 undeclared (first use in this function); did you mean =E2=
=80=98NHLT_MIC_ARRAY_4CH_1ST_GEOM=E2=80=99?
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 case NHLT_MIC_ARRAY_4CH_2ND_GEOM:
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~=
~~~~~~~~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 NHLT_MIC_ARRA=
Y_4CH_1ST_GEOM
>>> ../sound/hda/intel-nhlt.c:88:16: error: =E2=80=98MIC_ARRAY_4CH=E2=80=99=
 undeclared (first use in this function); did you mean =E2=80=98MIC_ARRAY=
_2CH=E2=80=99?
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 dmic_geo =3D MIC_ARRAY_4CH;
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 MIC_ARRAY_2CH
>>>  =C2=A0=C2=A0 AR=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 sound/i2c/built-in.a
>>>  =C2=A0=C2=A0 CC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 drivers/bluetooth/btmt=
ksdio.o
>>> ../sound/hda/intel-nhlt.c:90:9: error: =E2=80=98NHLT_MIC_ARRAY_VENDOR=
_DEFINED=E2=80=99 undeclared (first use in this function); did you mean =E2=
=80=98NHLT_MIC_ARRAY_4CH_L_SHAPED=E2=80=99?
>>>  =C2=A0=C2=A0=C2=A0=C2=A0 case NHLT_MIC_ARRAY_VENDOR_DEFINED:
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~=
~~~~~~~~~~~~~~~~
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 NHLT_MIC_ARRA=
Y_4CH_L_SHAPED
>>> ../sound/hda/intel-nhlt.c:92:26: error: dereferencing pointer to inco=
mplete type =E2=80=98struct nhlt_vendor_dmic_array_config=E2=80=99
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 dmic_geo =3D cfg_vendor->nb_mics;
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 ^~
>>> ../sound/hda/intel-nhlt.c: At top level:
>>> ../sound/hda/intel-nhlt.c:106:16: error: expected declaration specifi=
ers or =E2=80=98...=E2=80=99 before string constant
>>>  =C2=A0 MODULE_LICENSE("GPL v2");
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~
>>> ../sound/hda/intel-nhlt.c:107:20: error: expected declaration specifi=
ers or =E2=80=98...=E2=80=99 before string constant
>>>  =C2=A0 MODULE_DESCRIPTION("Intel NHLT driver");
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^~~~~~~~~~~~~~~~~~~
>>> cc1: some warnings being treated as errors
>>> make[3]: *** [../scripts/Makefile.build:266: sound/hda/intel-nhlt.o] =
Error 1
>>>
>>>
>>>
>=20
>=20

