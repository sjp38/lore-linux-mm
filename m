Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37CC6ECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:22:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03FE8206CD
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:22:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03FE8206CD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F5936B0007; Wed, 11 Sep 2019 03:22:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A5DA6B0008; Wed, 11 Sep 2019 03:22:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E2E56B000A; Wed, 11 Sep 2019 03:22:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD626B0007
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:22:26 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1A546180AD802
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:22:26 +0000 (UTC)
X-FDA: 75921796692.20.elbow56_4f60734af2d44
X-HE-Tag: elbow56_4f60734af2d44
X-Filterd-Recvd-Size: 3807
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp [114.179.232.162])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:22:25 +0000 (UTC)
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x8B7MKAk020343
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 11 Sep 2019 16:22:20 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8B7MK2T021862;
	Wed, 11 Sep 2019 16:22:20 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8B7MDR1021065;
	Wed, 11 Sep 2019 16:22:20 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-936117; Wed, 11 Sep 2019 16:21:14 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0439.000; Wed,
 11 Sep 2019 16:21:13 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: "osalvador@suse.de" <osalvador@suse.de>
CC: "mhocko@kernel.org" <mhocko@kernel.org>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 00/10] Hwpoison soft-offline rework
Thread-Topic: [PATCH 00/10] Hwpoison soft-offline rework
Thread-Index: AQHVZ8LTy7PIWQBirkyAnAoCBs9f5aclXX4AgAAOxICAAAOJAIAADMoA
Date: Wed, 11 Sep 2019 07:21:12 +0000
Message-ID: <20190911072112.GA12499@hori.linux.bs1.fc.nec.co.jp>
References: <20190910103016.14290-1-osalvador@suse.de>
 <20190911052956.GA9729@hori.linux.bs1.fc.nec.co.jp>
 <20190911062246.GA31960@hori.linux.bs1.fc.nec.co.jp>
 <59dce1bc205b10f67f17cf9d2e1e7a04@suse.de>
In-Reply-To: <59dce1bc205b10f67f17cf9d2e1e7a04@suse.de>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <80CDEFCDA81BC34D9226C8BC8FBFE853@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 08:35:26AM +0200, osalvador@suse.de wrote:
> On 2019-09-11 08:22, Naoya Horiguchi wrote:
> > I found another panic ...
>=20
> Hi Naoya,
>=20
> Thanks for giving it a try. Are these testcase public?
> I will definetely take a look and try to solve these cases.

It's available on https://github.com/Naoya-Horiguchi/mm_regression.
The README is a bit obsolete (sorry about that ...,) but you can run
the testcase like below:

  $ git clone https://github.com/Naoya-Horiguchi/mm_regression
  $ cd mm_regression
  mm_regression $ git clone https://github.com/Naoya-Horiguchi/test_core=20
  mm_regression $ make
  // you might need to install some dependencies like numa library and mce-=
inject tool
  mm_regression $ make update_recipes

To run the single testcase, run the commands like below:

  mm_regression $ RECIPEFILES=3Dcases/page_migration/hugetlb_migratepages_a=
llocate1_noovercommit.auto2 bash run.sh
  mm_regression $ RECIPEFILES=3Dcases/cases/mce_ksm_soft-offline_avoid_acce=
ss.auto2 bash run.sh
 =20
You can run a set of many testcases with the commands like below:

  mm_regression $ RECIPEFILES=3Dcases/cases/mce_ksm_* bash run.sh
  // run all ksm related testcases. I reproduced the panic with this comman=
d.

  mm_regression $ run_class=3Dsimple bash run.sh
  // run the set of minimum testcases I run for each releases.

Hopefully this will help you.

Thanks,
Naoya Horiguchi=


