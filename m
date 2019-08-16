Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76B37C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:47:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BD282086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:47:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BD282086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C54A6B0003; Fri, 16 Aug 2019 08:47:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7756D6B0005; Fri, 16 Aug 2019 08:47:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 663D66B0007; Fri, 16 Aug 2019 08:47:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0038.hostedemail.com [216.40.44.38])
	by kanga.kvack.org (Postfix) with ESMTP id 451C56B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:47:58 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E5362180AD805
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:47:57 +0000 (UTC)
X-FDA: 75828268194.26.use53_629a5df6fbe06
X-HE-Tag: use53_629a5df6fbe06
X-Filterd-Recvd-Size: 4077
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:47:57 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0EE7CAF59;
	Fri, 16 Aug 2019 12:47:56 +0000 (UTC)
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
To: Petr Vandrovec <petr@vandrovec.name>
Cc: Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>,
 Andrew Morton <akpm@linux-foundation.org>,
 bugzilla-daemon@bugzilla.kernel.org,
 Christian Koenig <christian.koenig@amd.com>, Huang Rui <ray.huang@amd.com>,
 David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
 Joerg Roedel <jroedel@suse.de>
References: <bug-204407-27@https.bugzilla.kernel.org/>
 <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
 <20190802203344.GD5597@bombadil.infradead.org>
 <1564780650.11067.50.camel@lca.pw>
 <20190802225939.GE5597@bombadil.infradead.org>
 <CA+i2_Dc-VrOUk8EVThwAE5HZ1-zFqONuW8Gojv+16UPsAqoM1Q@mail.gmail.com>
 <45258da8-2ce7-68c2-1ba0-84f6c0e634b1@suse.cz>
 <0287aace-fec1-d2d1-370f-657e80477717@vandrovec.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6a45a9b1-81ad-72c4-8f06-5d2cd87278ef@suse.cz>
Date: Fri, 16 Aug 2019 14:47:53 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <0287aace-fec1-d2d1-370f-657e80477717@vandrovec.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/15/19 9:13 PM, Petr Vandrovec wrote:
> Vlastimil=C2=A0Babka=C2=A0wrote=C2=A0on=C2=A08/15/2019=C2=A07:32=C2=A0A=
M:
>>
>> Does=C2=A0the=C2=A0issue=C2=A0still=C2=A0happen=C2=A0with=C2=A0rc4?=C2=
=A0Could=C2=A0you=C2=A0apply=C2=A0the=C2=A03=C2=A0attached
>> patches=C2=A0(work=C2=A0in=C2=A0progress),=C2=A0configure-enable=C2=A0=
CONFIG_DEBUG_PAGEALLOC=C2=A0and
>> CONFIG_PAGE_OWNER=C2=A0and=C2=A0boot=C2=A0kernel=C2=A0with=C2=A0debug_=
pagealloc=3Don=C2=A0page_owner=3Don
>> parameters?=C2=A0That=C2=A0should=C2=A0print=C2=A0stacktraces=C2=A0of=C2=
=A0allocation=C2=A0and=C2=A0first
>> freeing=C2=A0(assuming=C2=A0this=C2=A0is=C2=A0a=C2=A0double=C2=A0free)=
.
>=20
> Unfortunately -rc4 does not find any my SATA disks due to some=20
> misunderstanding between AHCI driver and HPT642L adapter (there is no=20
> device=C2=A007:00.1,=C2=A0HPT=C2=A0is=C2=A0single-function=C2=A0device=C2=
=A0at=C2=A007:00.0):
>=20
> [=C2=A0=C2=A0=C2=A018.003015]=C2=A0scsi=C2=A0host6:=C2=A0ahci
> [=C2=A0=C2=A0=C2=A018.006605]=C2=A0DMAR:=C2=A0DRHD:=C2=A0handling=C2=A0=
fault=C2=A0status=C2=A0reg=C2=A02
> [=C2=A0=C2=A0 18.006619] DMAR: [DMA Write] Request device [07:00.1] fau=
lt addr=20
> fffe0000=C2=A0[fault=C2=A0reason=C2=A002]=C2=A0Present=C2=A0bit=C2=A0in=
=C2=A0context=C2=A0entry=C2=A0is=C2=A0clear
> [=C2=A0=C2=A0=C2=A018.076616]=C2=A0DMAR:=C2=A0DRHD:=C2=A0handling=C2=A0=
fault=C2=A0status=C2=A0reg=C2=A0102
> [=C2=A0=C2=A0 18.085910] DMAR: [DMA Write] Request device [07:00.1] fau=
lt addr=20
> fffa0000=C2=A0[fault=C2=A0reason=C2=A002]=C2=A0Present=C2=A0bit=C2=A0in=
=C2=A0context=C2=A0entry=C2=A0is=C2=A0clear
> [=C2=A0=C2=A0=C2=A018.100989]=C2=A0DMAR:=C2=A0DRHD:=C2=A0handling=C2=A0=
fault=C2=A0status=C2=A0reg=C2=A0202
> [=C2=A0=C2=A0 18.110985] DMAR: [DMA Write] Request device [07:00.1] fau=
lt addr=20
> fffe0000=C2=A0[fault=C2=A0reason=C2=A002]=C2=A0Present=C2=A0bit=C2=A0in=
=C2=A0context=C2=A0entry=C2=A0is=C2=A0clear

Worth reporting as well, not nice regression.

> With iommu=3Doff disks are visible, but USB keyboard (and other USB=20
> devices)=C2=A0does=C2=A0not=C2=A0work:

I've been told iommu=3Dsoft might help.

> [=C2=A0=C2=A0 18.174802] ehci-pci 0000:00:1a.0: swiotlb buffer is full =
(sz: 8=20
> bytes),=C2=A0total=C2=A00=C2=A0(slots),=C2=A0used=C2=A00=C2=A0(slots)
> [=C2=A0=C2=A0 18.174804] ehci-pci 0000:00:1a.0: overflow 0x0000000ffdc7=
5ae8+8 of=20
> DMA=C2=A0mask=C2=A0ffffffff=C2=A0bus=C2=A0mask=C2=A00
> [=C2=A0=C2=A0 18.174815] WARNING: CPU: 2 PID: 508 at kernel/dma/direct.=
c:35=20
> report_addr+0x2e/0x50
> [=C2=A0=C2=A0=C2=A018.174816]=C2=A0Modules=C2=A0linked=C2=A0in:
> [=C2=A0=C2=A0 18.174818] CPU: 2 PID: 508 Comm: kworker/2:1 Tainted: G=20
>  =C2=A0=C2=A0T=C2=A05.3.0-rc4-64-00058-gd717b092e0b2=C2=A0#77
> [=C2=A0=C2=A0 18.174819] Hardware name: Dell Inc. Precision T3610/09M8Y=
8, BIOS A16=20
> 02/05/2018
> [=C2=A0=C2=A0=C2=A018.174822]=C2=A0Workqueue:=C2=A0usb_hub_wq=C2=A0hub_=
event
>=20
> I'll=C2=A0try=C2=A0to=C2=A0find=C2=A0-rc4=C2=A0configuration=C2=A0that=C2=
=A0has=C2=A0enabled=C2=A0debugging=C2=A0and=C2=A0can=C2=A0boot.=20
>=20
>=20
> Petr
>=20
>=20


