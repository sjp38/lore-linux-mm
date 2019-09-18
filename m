Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FA52C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 02:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F25CE21848
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 02:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F25CE21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 583576B0271; Tue, 17 Sep 2019 22:43:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5343F6B0272; Tue, 17 Sep 2019 22:43:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 423556B0273; Tue, 17 Sep 2019 22:43:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0023.hostedemail.com [216.40.44.23])
	by kanga.kvack.org (Postfix) with ESMTP id 24FEB6B0271
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 22:43:30 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C84ED8243770
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 02:43:29 +0000 (UTC)
X-FDA: 75946495338.09.egg10_5891ec75c3b1a
X-HE-Tag: egg10_5891ec75c3b1a
X-Filterd-Recvd-Size: 5524
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp [114.179.232.161])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 02:43:28 +0000 (UTC)
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x8I2hBIa003067
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 18 Sep 2019 11:43:11 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8I2hBKJ022445;
	Wed, 18 Sep 2019 11:43:11 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8I2c5ON016435;
	Wed, 18 Sep 2019 11:43:11 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-8621061; Wed, 18 Sep 2019 11:16:10 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0439.000; Wed,
 18 Sep 2019 11:16:09 +0900
From: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
To: David Hildenbrand <david@redhat.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "dan.j.williams@intel.com" <dan.j.williams@intel.com>
CC: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>,
        "longman@redhat.com" <longman@redhat.com>,
        "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
        "mst@redhat.com" <mst@redhat.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
Thread-Topic: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
Thread-Index: AQHVZIp2xk1cU6nEkk+ez7kL5reVFKcdvuyAgAAVnwCAAAk8gIAEZuMAgAAgogCADDvdgIAATZsAgAAnMACAAA0zAIABCyeA
Date: Wed, 18 Sep 2019 02:16:08 +0000
Message-ID: <6796e499-ea0e-ecf0-00f8-2bb9f988c9ae@vx.jp.nec.com>
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
 <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com>
 <e762ee45-43e3-975a-ad19-065f07d1440f@vx.jp.nec.com>
 <40a1ce2e-1384-b869-97d0-7195b5b47de0@redhat.com>
 <6a99e003-e1ab-b9e8-7b25-bc5605ab0eb2@vx.jp.nec.com>
 <e4e54258-e83b-cf0b-b66e-9874be6b5122@redhat.com>
 <31fd3c86-5852-1863-93bd-8df9da9f95b4@vx.jp.nec.com>
 <38e58d23-c20b-4e68-5f56-20bba2be2d6c@redhat.com>
 <3d27953a-88b8-5a7c-de3c-041f8b4436f6@vx.jp.nec.com>
 <ab946240-d335-b803-2f70-d255abd30b43@redhat.com>
In-Reply-To: <ab946240-d335-b803-2f70-d255abd30b43@redhat.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.135]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6D5D8DA702E6494CB02FAFB0458A0DCA@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.004999, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/09/17 19:20, David Hildenbrand wrote:
> On 17.09.19 11:32, Toshiki Fukasawa wrote:
>> On 2019/09/17 16:13, David Hildenbrand wrote:
>>> On 17.09.19 04:34, Toshiki Fukasawa wrote:
>>>> On 2019/09/09 16:46, David Hildenbrand wrote:
>>>>> Let's take a step back here to understand the issues I am aware of. I
>>>>> think we should solve this for good now:
>>>>>
>>>>> A PFN walker takes a look at a random PFN at a random point in time. =
It
>>>>> finds a PFN with SECTION_MARKED_PRESENT && !SECTION_IS_ONLINE. The
>>>>> options are:
>>>>>
>>>>> 1. It is buddy memory (add_memory()) that has not been online yet. Th=
e
>>>>> memmap contains garbage. Don't access.
>>>>>
>>>>> 2. It is ZONE_DEVICE memory with a valid memmap. Access it.
>>>>>
>>>>> 3. It is ZONE_DEVICE memory with an invalid memmap, because the secti=
on
>>>>> is only partially present: E.g., device starts at offset 64MB within =
a
>>>>> section or the device ends at offset 64MB within a section. Don't acc=
ess it.
>>>>
>>>> I don't agree with case #3. In the case, struct page area is not alloc=
ated on
>>>> ZONE_DEVICE, but is allocated on system memory. So I think we can acce=
ss the
>>>> struct pages. What do you mean "invalid memmap"?
>>> No, that's not the case. There is no memory, especially not system
>>> memory. We only allow partially present sections (sub-section memory
>>> hotplug) for ZONE_DEVICE.
>>
>> Let me clear my thoughts. If I read correctly, the struct pages for sect=
ions
>> (including partially present sections) on ZONE_DEVICE are allocated by
>> vmemmap_populate(). And all the struct pages except (altmap->base_pfn) t=
o
>> (altmap->base_pfn + altmap->reserve) are initialized by memmap_init_zone=
()
>> and memmap_init_zone_device().
>>
>> Do struct pages for partially present sections go through a different pr=
ocess?
>=20
> No. However, the memmap is initialized via move_pfn_range_to_zone(). So
> partially present sections will have partially uninitialized memmaps.
>=20
Thank you for explanation.
To my understanding, depending on architecture, the situation is possible
that the struct pages for entire section is allocated, but only pages
in the zone are initialized.

Thanks,
Toshiki Fukasawa=


