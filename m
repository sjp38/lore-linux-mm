Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBDEDC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:29:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 847C521726
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:29:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 847C521726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 090636B0003; Wed,  4 Sep 2019 16:29:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 040A16B0006; Wed,  4 Sep 2019 16:29:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E98D86B0007; Wed,  4 Sep 2019 16:29:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id C93336B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:29:16 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 31615180AD801
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:29:16 +0000 (UTC)
X-FDA: 75898377912.18.pig06_8ae1ba8f80e4b
X-HE-Tag: pig06_8ae1ba8f80e4b
X-Filterd-Recvd-Size: 5039
Received: from mga17.intel.com (mga17.intel.com [192.55.52.151])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:29:14 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Sep 2019 13:29:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,468,1559545200"; 
   d="scan'208";a="190278966"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by FMSMGA003.fm.intel.com with ESMTP; 04 Sep 2019 13:29:12 -0700
Received: from fmsmsx151.amr.corp.intel.com (10.18.125.4) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Wed, 4 Sep 2019 13:29:12 -0700
Received: from crsmsx152.amr.corp.intel.com (172.18.7.35) by
 FMSMSX151.amr.corp.intel.com (10.18.125.4) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Wed, 4 Sep 2019 13:20:22 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.249]) by
 CRSMSX152.amr.corp.intel.com ([169.254.5.223]) with mapi id 14.03.0439.000;
 Wed, 4 Sep 2019 14:20:21 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka
	<vbabka@suse.cz>
CC: zhong jiang <zhongjiang@huawei.com>, "mhocko@kernel.org"
	<mhocko@kernel.org>, "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Aneesh Kumar K.V
	<aneesh.kumar@linux.vnet.ibm.com>
Subject: RE: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
Thread-Topic: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
Thread-Index: AQHVYwudPt5si0bTnEuchA1jrW3MqKcbxUIAgAB74AD//7RlYA==
Date: Wed, 4 Sep 2019 20:20:20 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E898E9C17@CRSMSX101.amr.corp.intel.com>
References: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com>
	<5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
 <20190904114820.42d9c4daf445ded3d0da52ab@linux-foundation.org>
In-Reply-To: <20190904114820.42d9c4daf445ded3d0da52ab@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiM2QzNjAwMjUtNzk3Ny00MzU5LWJiYTQtMmNjNGVkZmIzMjUxIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiaFJIcythc1NNZ2VGam41eVwvREN2ZzQ0TDVRelpUYVwvWWZOM3BraHJxa1Q5RlJSdlE2cFdkdVRianlWYW9CbTByIn0=
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.2.0.6
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Subject: Re: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
>=20
> On Wed, 4 Sep 2019 13:24:58 +0200 Vlastimil Babka <vbabka@suse.cz>
> wrote:
>=20
> > On 9/4/19 12:26 PM, zhong jiang wrote:
> > > With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages"=
'
> > > compare with zero. And __get_user_pages_locked will return an long
> value.
> > > Hence, Convert the long to compare with zero is feasible.
> >
> > It would be nicer if the parameter nr_pages was long again instead of
> > unsigned long (note there are two variants of the function, so both sho=
uld
> be changed).
>=20
> nr_pages should be unsigned - it's a count of pages!
>=20
> The bug is that __get_user_pages_locked() returns a signed long which can
> be a -ve errno.

Ok...  This is my bad...  I think this is the correct fix though.  Not chan=
ging the type of nr_pages.

Sorry,
Ira

>=20
> I think it's best if __get_user_pages_locked() is to get itself a new loc=
al with
> the same type as its return value.  Something like:
>=20
> --- a/mm/gup.c~a
> +++ a/mm/gup.c
> @@ -1450,6 +1450,7 @@ static long check_and_migrate_cma_pages(
>  	bool drain_allow =3D true;
>  	bool migrate_allow =3D true;
>  	LIST_HEAD(cma_page_list);
> +	long ret;
>=20
>  check_again:
>  	for (i =3D 0; i < nr_pages;) {
> @@ -1511,17 +1512,18 @@ check_again:
>  		 * again migrating any new CMA pages which we failed to
> isolate
>  		 * earlier.
>  		 */
> -		nr_pages =3D __get_user_pages_locked(tsk, mm, start,
> nr_pages,
> +		ret =3D __get_user_pages_locked(tsk, mm, start, nr_pages,
>  						   pages, vmas, NULL,
>  						   gup_flags);
>=20
> -		if ((nr_pages > 0) && migrate_allow) {
> +		nr_pages =3D ret;
> +		if (ret > 0 && migrate_allow) {
>  			drain_allow =3D true;
>  			goto check_again;
>  		}
>  	}
>=20
> -	return nr_pages;
> +	return ret;
>  }
>  #else
>  static long check_and_migrate_cma_pages(struct task_struct *tsk,
>=20
>=20


