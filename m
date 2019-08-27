Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CF6DC3A59F
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 01:41:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B6462080C
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 01:41:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B6462080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08A0B6B0007; Mon, 26 Aug 2019 21:41:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03B576B0008; Mon, 26 Aug 2019 21:41:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6B5F6B000A; Mon, 26 Aug 2019 21:41:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0092.hostedemail.com [216.40.44.92])
	by kanga.kvack.org (Postfix) with ESMTP id C03076B0007
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 21:41:19 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 627D6485C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:41:19 +0000 (UTC)
X-FDA: 75866505078.17.face01_b54c38272c34
X-HE-Tag: face01_b54c38272c34
X-Filterd-Recvd-Size: 5407
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp [114.179.232.161])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:41:17 +0000 (UTC)
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x7R1fB5g018428
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 27 Aug 2019 10:41:11 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x7R1fBC7004398;
	Tue, 27 Aug 2019 10:41:11 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x7R1f8NS009523;
	Tue, 27 Aug 2019 10:41:11 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-7897375; Tue, 27 Aug 2019 10:34:31 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0439.000; Tue,
 27 Aug 2019 10:34:29 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Oscar Salvador <osalvador@suse.de>
CC: "mhocko@kernel.org" <mhocko@kernel.org>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "vbabka@suse.cz" <vbabka@suse.cz>
Subject: Re: poisoned pages do not play well in the buddy allocator
Thread-Topic: poisoned pages do not play well in the buddy allocator
Thread-Index: AQHVW/rikgbcCOwjjUKpu7s54tdytqcNoE2A
Date: Tue, 27 Aug 2019 01:34:29 +0000
Message-ID: <20190827013429.GA5125@hori.linux.bs1.fc.nec.co.jp>
References: <20190826104144.GA7849@linux>
In-Reply-To: <20190826104144.GA7849@linux>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5C3D0DDFB19E7145A3A8CE56A8E69AE7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 12:41:50PM +0200, Oscar Salvador wrote:
> Hi,
>=20
> When analyzing a problem reported by one of our customers, I stumbbled up=
on an issue
> that origins from the fact that poisoned pages end up in the buddy alloca=
tor.
>=20
> Let me break down the stepts that lie to the problem:
>=20
> 1) We soft-offline a page
> 2) Page gets flagged as HWPoison and is being sent to the buddy allocator=
.
>    This is done through set_hwpoison_free_buddy_page().
> 3) Kcompactd wakes up in order to perform some compaction.
> 4) compact_zone() will call migrate_pages()
> 5) migrate_pages() will try to get a new page from compaction_alloc() to =
migrate to
> 6) if cc->freelist is empty, compaction_alloc() will call isolate_free_pa=
gesblock()
> 7) isolate_free_pagesblock only checks for PageBuddy() to assume that a p=
age is OK
>    to be used to migrate to. Since HWPoisoned page are also PageBuddy, we=
 add
>    the page to the list. (same problem exists in fast_isolate_freepages()=
).
>=20
> The outcome of that is that we end up happily handing poisoned pages in c=
ompaction_alloc,
> so if we ever got a fault on that page through *_fault, we will return VM=
_FAULT_HWPOISON,
> and the process will be killed.
>=20
> I first though that I could get away with it by checking PageHWPoison in
> {fast_isolate_freepages/isolate_free_pagesblock}, but not really.
> It might be that the page we are checking is an order > 0 page, so the fi=
rst page
> might not be poisoned, but the one the follows might be, and we end up in=
 the
> same situation.

Yes, this is a whole point of the current implementation.

>=20
> After some more thought, I really came to the conclusion that HWPoison pa=
ges should not
> really be in the buddy allocator, as this is only asking for problems.
> In this case it is only compaction code, but it could be happening somewh=
ere else,
> and one would expect that the pages you got from the buddy allocator are =
__ready__ to use.
>=20
> I __think__ that we thought we were safe to put HWPoison pages in the bud=
dy allocator as we
> perform healthy checks when getting a page from there, so we skip poisone=
d pages
>=20
> Of course, this is not the end of the story, now that someone got a page,=
 if he frees it,
> there is a high chance that this page ends up in a pcplist (I saw that).
> Unless we are on CONFIG_VM_DEBUG, we do not check for the health of pages=
 got from pcplist,
> as we do when getting a page from the buddy allocator.
>=20
> I checked [1], and it seems that [2] was going towards fixing this kind o=
f issue.
>=20
> I think it is about time to revamp the whole thing.
>=20
> @Naoya: I could give it a try if you are busy.

Thanks for raising hand. That's really wonderful. I think that the series [=
1] is not
merge yet but not rejected yet, so feel free to reuse/update/revamp it.

>=20
> [1] https://lore.kernel.org/linux-mm/1541746035-13408-1-git-send-email-n-=
horiguchi@ah.jp.nec.com/
> [2] https://lore.kernel.org/linux-mm/1541746035-13408-9-git-send-email-n-=
horiguchi@ah.jp.nec.com/
>=20
> --=20
> Oscar Salvador
> SUSE L3
> =


