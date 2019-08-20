Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1B09C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A85A214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:08:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A85A214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2440F6B0007; Tue, 20 Aug 2019 03:08:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F3066B0008; Tue, 20 Aug 2019 03:08:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E2516B000A; Tue, 20 Aug 2019 03:08:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id E27956B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:08:46 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6BD298248AA7
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:08:46 +0000 (UTC)
X-FDA: 75841928652.14.art24_86a71e6132727
X-HE-Tag: art24_86a71e6132727
X-Filterd-Recvd-Size: 3418
Received: from mga09.intel.com (mga09.intel.com [134.134.136.24])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:08:45 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Aug 2019 00:08:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,407,1559545200"; 
   d="scan'208";a="172364843"
Received: from shao2-debian.sh.intel.com (HELO [10.239.13.6]) ([10.239.13.6])
  by orsmga008.jf.intel.com with ESMTP; 20 Aug 2019 00:08:42 -0700
Subject: Re: [kbuild-all] [rgushchin:fix_vmstats 21/221]
 include/asm-generic/5level-fixup.h:14:18: error: unknown type name 'pgd_t';
 did you mean 'pid_t'?
To: Roman Gushchin <guro@fb.com>, Qian Cai <cai@lca.pw>
Cc: Linux Memory Management List <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Johannes Weiner <hannes@cmpxchg.org>, kbuild test robot <lkp@intel.com>,
 "kbuild-all@01.org" <kbuild-all@01.org>
References: <201908131117.SThHOrZO%lkp@intel.com>
 <1565707945.8572.10.camel@lca.pw>
 <20190814004548.GA18813@tower.DHCP.thefacebook.com>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <3edbc032-4cc3-a87c-03c9-2b2fcaec32e8@intel.com>
Date: Tue, 20 Aug 2019 15:08:43 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190814004548.GA18813@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/14/19 8:45 AM, Roman Gushchin wrote:
> On Tue, Aug 13, 2019 at 10:52:25AM -0400, Qian Cai wrote:
>> On Tue, 2019-08-13 at 11:33 +0800, kbuild test robot wrote:
>>> tree:=C2=A0=C2=A0=C2=A0https://github.com/rgushchin/linux.git fix_vms=
tats
>>> head:=C2=A0=C2=A0=C2=A04ec858b5201ae067607e82706b36588631c1b990
>>> commit: 938dda772d9d05074bfe1baa0dc18873fbf4fedb [21/221] include/asm=
-
>>> generic/5level-fixup.h: fix variable 'p4d' set but not used
>>> config: parisc-c3000_defconfig (attached as .config)
>>> compiler: hppa-linux-gcc (GCC) 7.4.0
>>> reproduce:
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0wget https://urldefe=
nse.proofpoint.com/v2/url?u=3Dhttps-3A__raw.githubusercontent.com_intel_l=
kp-2Dtests_master_sbin_mak&d=3DDwIFaQ&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3DjJYg=
tDM7QT-W-Fz_d29HYQ&m=3DTOir6b4wrmTSQpeaAQcpcHZUk9uWkTRUOJaNgbh4m-o&s=3D0I=
eTTEfMlxl9cDI9YAz2Zji8QaiE8B29qreDUnvID5E&e=3D
>>> e.cross -O ~/bin/make.cross
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0chmod +x ~/bin/make.=
cross
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0git checkout 938dda7=
72d9d05074bfe1baa0dc18873fbf4fedb
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0# save the attached =
.config to linux build tree
>>>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0GCC_VERSION=3D7.4.0 =
make.cross ARCH=3Dparisc
>> I am unable to reproduce this on today's linux-next tree. What's point=
 of
>> testing this particular personal git tree/branch?
> I'm using it to test my patches before sending them to public mailing l=
ists.
> It really helps with reducing the number of trivial issues and upstream
> iterations as a consequence. And not only trivial...
>
> If there is a way to prevent notifying anyone but me, please, let me kn=
ow,
> I'm happy to do it.
>
Hi Roman,

The reports should only be sent to you now. please see=20
https://github.com/intel/lkp-tests/blob/master/repo/linux/rgushchin

Best Regards,
Rong Chen

