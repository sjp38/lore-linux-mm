Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2777CC433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 06:00:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2D6721924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 06:00:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2D6721924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E86806B0005; Mon,  9 Sep 2019 02:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E35EF6B0006; Mon,  9 Sep 2019 02:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D24AF6B0007; Mon,  9 Sep 2019 02:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id AC51F6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 02:00:21 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4442F180AD7C3
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 06:00:21 +0000 (UTC)
X-FDA: 75914332242.12.slave44_77456bf540829
X-HE-Tag: slave44_77456bf540829
X-Filterd-Recvd-Size: 7859
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp [114.179.232.161])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 06:00:19 +0000 (UTC)
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x89606CC012624
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 9 Sep 2019 15:00:06 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x89606kU007159;
	Mon, 9 Sep 2019 15:00:06 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x895o1x2017817;
	Mon, 9 Sep 2019 15:00:06 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.151] [10.38.151.151]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-853262; Mon, 9 Sep 2019 14:48:36 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC23GP.gisp.nec.co.jp ([10.38.151.151]) with mapi id 14.03.0439.000; Mon, 9
 Sep 2019 14:48:35 +0900
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
Thread-Index: AQHVZIp2xk1cU6nEkk+ez7kL5reVFKcdvuyAgAAVnwCAAAk8gIAEZuMA
Date: Mon, 9 Sep 2019 05:48:34 +0000
Message-ID: <6a99e003-e1ab-b9e8-7b25-bc5605ab0eb2@vx.jp.nec.com>
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
 <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com>
 <e762ee45-43e3-975a-ad19-065f07d1440f@vx.jp.nec.com>
 <40a1ce2e-1384-b869-97d0-7195b5b47de0@redhat.com>
In-Reply-To: <40a1ce2e-1384-b869-97d0-7195b5b47de0@redhat.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.135]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <17BE49E6AA775C488AB78E3047A82E32@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/09/06 19:35, David Hildenbrand wrote:
> On 06.09.19 12:02, Toshiki Fukasawa wrote:
>> Thank you for your feedback.
>>
>> On 2019/09/06 17:45, David Hildenbrand wrote:
>>> On 06.09.19 10:09, Toshiki Fukasawa wrote:
>>>> A kernel panic is observed during reading
>>>> /proc/kpage{cgroup,count,flags} for first few pfns allocated by
>>>> pmem namespace:
>>>>
>>>> BUG: unable to handle page fault for address: fffffffffffffffe
>>>> [  114.495280] #PF: supervisor read access in kernel mode
>>>> [  114.495738] #PF: error_code(0x0000) - not-present page
>>>> [  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
>>>> [  114.496713] Oops: 0000 [#1] SMP PTI
>>>> [  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1
>>>> [  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), =
BIOS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
>>>> [  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
>>>> [  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 0=
0 41 54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c=
7 <48> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
>>>> [  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
>>>> [  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 000000=
0000000000
>>>> [  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd0=
7489000000
>>>> [  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 000000=
0000000000
>>>> [  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 000000=
0000240000
>>>> [  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5=
e601a0ff08
>>>> [  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) k=
nlGS:0000000000000000
>>>> [  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> [  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 000000=
00000006e0
>>>> [  114.506401] Call Trace:
>>>> [  114.506660]  kpageflags_read+0xb1/0x130
>>>> [  114.507051]  proc_reg_read+0x39/0x60
>>>> [  114.507387]  vfs_read+0x8a/0x140
>>>> [  114.507686]  ksys_pread64+0x61/0xa0
>>>> [  114.508021]  do_syscall_64+0x5f/0x1a0
>>>> [  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>>> [  114.508844] RIP: 0033:0x7f0266ba426b
>>>>
>>>> The first few pages of ZONE_DEVICE expressed as the range
>>>> (altmap->base_pfn) to (altmap->base_pfn + altmap->reserve) are
>>>> skipped by struct page initialization. Some pfn walkers like
>>>> /proc/kpage{cgroup, count, flags} can't handle these uninitialized
>>>> struct pages, which causes the error.
>>>>
>>>> In previous discussion, Dan seemed to have concern that the struct
>>>> page area of some pages indicated by vmem_altmap->reserve may not
>>>> be allocated. (See https://lore.kernel.org/lkml/CAPcyv4i5FjTOnPbXNcTzv=
t+e6RQYow0JRQwSFuxaa62LSuvzHQ@mail.gmail.com/)
>>>> However, arch_add_memory() called by devm_memremap_pages() allocates
>>>> struct page area for pages containing addresses in the range
>>>> (res.start) to (res.start + resource_size(res)), which include the
>>>> pages indicated by vmem_altmap->reserve. If I read correctly, it is
>>>> allocated as requested at least on x86_64. Also, memmap_init_zone()
>>>> initializes struct pages in the same range.
>>>> So I think the struct pages should be initialized.>
>>>
>>> For !ZONE_DEVICE memory, the memmap is valid with SECTION_IS_ONLINE -
>>> for the whole section. For ZONE_DEVICE memory we have no such
>>> indication. In any section that is !SECTION_IS_ONLINE and
>>> SECTION_MARKED_PRESENT, we could have any subsections initialized. >
>>> The only indication I am aware of is pfn_zone_device_reserved() - which
>>> seems to check exactly what you are trying to skip here.
>>>
>>> Can't you somehow use pfn_zone_device_reserved() ? Or if you considered
>>> that already, why did you decide against it?
>>
>> No, in current approach this function is no longer needed.
>> The reason why we change the approach is that all pfn walkers
>> have to be aware of the uninitialized struct pages.
>=20
> We should use the same strategy for all pfn walkers then (effectively
> get rid of pfn_zone_device_reserved() if that's what we want).

True, but this patch replaces "/proc/kpageflags: do not use uninitialized
struct pages". If we initialize the uninitialized struct pages, no pfn walk=
er
will need to be aware of them.

>=20
>>
>> As for SECTION_IS_ONLINE, I'm not sure now.
>> I will look into it next week.
>=20
> SECTION_IS_ONLINE does currently not apply to ZONE_DEVICE and due to
> sub-section support for ZONE_DEVICE, it cannot easily be reused.
>=20
It seems that SECTION_IS_ONLINE and SECTION_MARKED_PRESENT can be used to
distinguish uninitialized struct pages if we can apply them to ZONE_DEVICE,
but that is no longer necessary with this approach.

Thanks,
Toshiki Fukasawa=


