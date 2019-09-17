Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52EC1C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 02:43:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D90A20678
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 02:43:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D90A20678
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA4E76B0003; Mon, 16 Sep 2019 22:43:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A56366B0005; Mon, 16 Sep 2019 22:43:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96B746B0006; Mon, 16 Sep 2019 22:43:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0246.hostedemail.com [216.40.44.246])
	by kanga.kvack.org (Postfix) with ESMTP id 759446B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 22:43:20 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 1A53A824CA23
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 02:43:20 +0000 (UTC)
X-FDA: 75942866160.18.sail22_1cf0dcb62ec57
X-HE-Tag: sail22_1cf0dcb62ec57
X-Filterd-Recvd-Size: 4553
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp [114.179.232.161])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 02:43:18 +0000 (UTC)
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x8H2h6li025318
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 17 Sep 2019 11:43:06 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8H2h6wQ022753;
	Tue, 17 Sep 2019 11:43:06 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8H2eBCX014414;
	Tue, 17 Sep 2019 11:43:06 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-1148208; Tue, 17 Sep 2019 11:34:44 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0439.000; Tue,
 17 Sep 2019 11:34:43 +0900
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
Thread-Index: AQHVZIp2xk1cU6nEkk+ez7kL5reVFKcdvuyAgAAVnwCAAAk8gIAEZuMAgAAgogCADDvdgA==
Date: Tue, 17 Sep 2019 02:34:43 +0000
Message-ID: <31fd3c86-5852-1863-93bd-8df9da9f95b4@vx.jp.nec.com>
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
 <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com>
 <e762ee45-43e3-975a-ad19-065f07d1440f@vx.jp.nec.com>
 <40a1ce2e-1384-b869-97d0-7195b5b47de0@redhat.com>
 <6a99e003-e1ab-b9e8-7b25-bc5605ab0eb2@vx.jp.nec.com>
 <e4e54258-e83b-cf0b-b66e-9874be6b5122@redhat.com>
In-Reply-To: <e4e54258-e83b-cf0b-b66e-9874be6b5122@redhat.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.135]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E6C6D8924A90DA4C8038847B427D5E31@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.023457, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/09/09 16:46, David Hildenbrand wrote:
> Let's take a step back here to understand the issues I am aware of. I
> think we should solve this for good now:
>=20
> A PFN walker takes a look at a random PFN at a random point in time. It
> finds a PFN with SECTION_MARKED_PRESENT && !SECTION_IS_ONLINE. The
> options are:
>=20
> 1. It is buddy memory (add_memory()) that has not been online yet. The
> memmap contains garbage. Don't access.
>=20
> 2. It is ZONE_DEVICE memory with a valid memmap. Access it.
>=20
> 3. It is ZONE_DEVICE memory with an invalid memmap, because the section
> is only partially present: E.g., device starts at offset 64MB within a
> section or the device ends at offset 64MB within a section. Don't access =
it.

I don't agree with case #3. In the case, struct page area is not allocated =
on
ZONE_DEVICE, but is allocated on system memory. So I think we can access th=
e
struct pages. What do you mean "invalid memmap"?

>=20
> 4. It is ZONE_DEVICE memory with an invalid memmap, because the memmap
> was not initialized yet. memmap_init_zone_device() did not yet succeed
> after dropping the mem_hotplug lock in mm/memremap.c. Don't access it.
>=20
> 5. It is reserved ZONE_DEVICE memory ("pages mapped, but reserved for
> driver") with an invalid memmap. Don't access it.
>=20
> I can see that your patch tries to make #5 vanish by initializing the
> memmap, fair enough. #3 and #4 can't be detected. The PFN walker could
> still stumble over uninitialized memmaps.
> =


