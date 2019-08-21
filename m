Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6229C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 19:19:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E89E216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 19:19:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="PBtD5w2K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E89E216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 054226B029D; Wed, 21 Aug 2019 15:19:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 004AF6B029F; Wed, 21 Aug 2019 15:19:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0D8F6B02A0; Wed, 21 Aug 2019 15:19:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id BAEF16B029D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:19:21 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 7AFDF181AC9BA
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:19:21 +0000 (UTC)
X-FDA: 75847398522.29.grain15_17618cd106902
X-HE-Tag: grain15_17618cd106902
X-Filterd-Recvd-Size: 9854
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760051.outbound.protection.outlook.com [40.107.76.51])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:19:20 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=W6zoWVRyRWv8NT117LIHNpoW0573KB1pE8VM6Kl05fu/a/+fkSNGvgkLbybMH2P3Vv18LK0Lr23Ph3/UbvDpkDsmVoi7uDGKSLeGWXGPHNRiZMwTC71xFDo6idNcQPt/EYVnncDvQqCr1wJWO2bNmH6H2iztIbDxUyllZMkrxnWIv9R13n3MjKCbjmbeVEc37K2JTCaIMC0WMgXn9GLRBIvfKgRuiMv9+pjwLswY4Awc40LySq8ZArokbOqypxYT88mbnjAB0II40eqlNut+jagCax4UgxxYn82YvMsowIgTF9V6zBANQ6dmrMuRmey3eekF4acQOau5ysP+zPFWlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=XS3OAXApQLJ/1wXmSZOjcV1W9UopVbrzv6+XGmjbVls=;
 b=igXxl4750RPR/IP4Q8+P2M19i9YK9LGInGf6y/IHjauzDSK4bHOl/wR9sRIyvH3oaIqUN1yHIAqWRyG929iFBDG1D0IrZL7eSrRKUXXUwrVOWPrjwVp7iDHinl5l18ngc3+iylKZhEE8ULHovxknVQggRXcTc/9uwHrOqn1kUpu/HMzf8tmPKOd9q3D2emGQ20mN5iJRMz8LRYZ5dFjXqh1s1YAq5ZK2MKwRkKixj+gU7fnyphoxa0BFYYVUUMJfHR1F0yKSnJrzVGGcEWYVQaG1RuiR9Rteyq0mKPbd7cOABxz3t9n/zO+TbXAjTxeq6FIHVOdPqw1G2E+RJWeCWg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=vmware.com; dmarc=pass action=none header.from=vmware.com;
 dkim=pass header.d=vmware.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=XS3OAXApQLJ/1wXmSZOjcV1W9UopVbrzv6+XGmjbVls=;
 b=PBtD5w2KXIIgS+hUZFEa49DifjZYC/vyaBY4iyHjiFXWT0Q8An1Tf3I7EMSiFbtdsIOaOyYefPLOS6kQkeLhoIQT06pvtTT6352U5MMC6LBws/gx0CkNKff50HhdXVeADYO8RHWimBo+hoOvwwDPGBDW3W82WJe6/2Fa8X1Vj7Q=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB3925.namprd05.prod.outlook.com (52.135.195.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2199.7; Wed, 21 Aug 2019 19:19:18 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::1541:ed53:784a:6376]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::1541:ed53:784a:6376%5]) with mapi id 15.20.2199.011; Wed, 21 Aug 2019
 19:19:18 +0000
From: Nadav Amit <namit@vmware.com>
To: David Hildenbrand <david@redhat.com>
CC: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm/balloon_compaction: Informative allocation warnings
Thread-Topic: [PATCH v2] mm/balloon_compaction: Informative allocation
 warnings
Thread-Index:
 AQHVWEJHWn7VmeZ5cEugJmetWObq/6cF9CyAgAAAcQCAAAHXgIAAATcAgAAAlgCAAAHhgA==
Date: Wed, 21 Aug 2019 19:19:18 +0000
Message-ID: <9DDD9A0D-C88C-4EEF-A41B-E5646BDEF414@vmware.com>
References: <20190821094159.40795-1-namit@vmware.com>
 <75ff92c2-7ae2-c4a6-cd1f-44741e29d20e@redhat.com>
 <4E10A342-9A51-4C1F-8E5A-8005AACEF4CE@vmware.com>
 <497b1189-8e1d-2926-ee5e-9077fcceb04b@redhat.com>
 <36AC2460-9E88-4BAF-B793-A14A00E41617@vmware.com>
 <3873b6ab-de6d-cac2-90e8-541fe86e2005@redhat.com>
In-Reply-To: <3873b6ab-de6d-cac2-90e8-541fe86e2005@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 47b123e6-436a-4c10-2780-08d7266c76bc
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB3925;
x-ms-traffictypediagnostic: BYAPR05MB3925:
x-microsoft-antispam-prvs:
 <BYAPR05MB392575DA11B2F6C2CAC38183D0AA0@BYAPR05MB3925.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 0136C1DDA4
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(366004)(136003)(39860400002)(376002)(396003)(199004)(189003)(54906003)(186003)(486006)(53936002)(316002)(6512007)(5660300002)(26005)(478600001)(476003)(66946007)(64756008)(76176011)(6916009)(66446008)(53546011)(6506007)(66476007)(33656002)(6436002)(6486002)(66556008)(102836004)(14454004)(99286004)(76116006)(229853002)(256004)(305945005)(446003)(66066001)(2906002)(8676002)(6246003)(36756003)(86362001)(25786009)(8936002)(2616005)(71190400001)(4326008)(71200400001)(11346002)(7736002)(3846002)(6116002)(81156014)(14444005)(81166006);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB3925;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 3Xz5uBgO+veO4+oiTVhIswxusJvfnnxHx0DKBsx+9z2DxC8Wayp9CA3LnK3dQr0HZwu5+cHyQRLCoZOUp6qT8NTUAqvyWcD677hAN03/GtTqARn5BlEcEuNpE5r95ZwttnqtvqwjYGH6dwlHZ2HmXaUTRso/J1Xfzq+2kNFJdii8wRwcAI7Siu1CMV1d7R+mxhQ6UDYBHIg4+xV5ZqgwtKWxZYGLsS111YIXMPuSOF8H+/3HjnZOPL+IbbWqPoFOPcaBH063D1q6M0N38RgaGYt4G/9aoQ6CjsfmiZPdkLBVbod/7LhPn6RG1o02T2as3hq8QIbBlRJ/66JP5UeNiSjk5ZjMb1XHAB1VgZXzORoUOM2HteDqf3BO9CPvVCJZfHSt/f+MdDYw6Z/sAogWIGVAmPhFP6N0Pla2hvg5KJ0=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F2EB266CFF731C4798729C491FC45D72@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 47b123e6-436a-4c10-2780-08d7266c76bc
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Aug 2019 19:19:18.4501
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: OAGZTuLecOGKeJDRewSHIP3AZr9oyY7dPrnJ8qqBJSGY6gCjkVh+t+bWXPGbXS8gcB/cXJMnRGlXxiavVx/FWA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB3925
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Aug 21, 2019, at 12:12 PM, David Hildenbrand <david@redhat.com> wrote:
>=20
> On 21.08.19 21:10, Nadav Amit wrote:
>>> On Aug 21, 2019, at 12:06 PM, David Hildenbrand <david@redhat.com> wrot=
e:
>>>=20
>>> On 21.08.19 20:59, Nadav Amit wrote:
>>>>> On Aug 21, 2019, at 11:57 AM, David Hildenbrand <david@redhat.com> wr=
ote:
>>>>>=20
>>>>> On 21.08.19 11:41, Nadav Amit wrote:
>>>>>> There is no reason to print generic warnings when balloon memory
>>>>>> allocation fails, as failures are expected and can be handled
>>>>>> gracefully. Since VMware balloon now uses balloon-compaction
>>>>>> infrastructure, and suppressed these warnings before, it is also
>>>>>> beneficial to suppress these warnings to keep the same behavior that=
 the
>>>>>> balloon had before.
>>>>>>=20
>>>>>> Since such warnings can still be useful to indicate that the balloon=
 is
>>>>>> over-inflated, print more informative and less frightening warning i=
f
>>>>>> allocation fails instead.
>>>>>>=20
>>>>>> Cc: David Hildenbrand <david@redhat.com>
>>>>>> Cc: Jason Wang <jasowang@redhat.com>
>>>>>> Signed-off-by: Nadav Amit <namit@vmware.com>
>>>>>>=20
>>>>>> ---
>>>>>>=20
>>>>>> v1->v2:
>>>>>> * Print informative warnings instead suppressing [David]
>>>>>> ---
>>>>>> mm/balloon_compaction.c | 7 ++++++-
>>>>>> 1 file changed, 6 insertions(+), 1 deletion(-)
>>>>>>=20
>>>>>> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
>>>>>> index 798275a51887..0c1d1f7689f0 100644
>>>>>> --- a/mm/balloon_compaction.c
>>>>>> +++ b/mm/balloon_compaction.c
>>>>>> @@ -124,7 +124,12 @@ EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
>>>>>> struct page *balloon_page_alloc(void)
>>>>>> {
>>>>>> 	struct page *page =3D alloc_page(balloon_mapping_gfp_mask() |
>>>>>> -				       __GFP_NOMEMALLOC | __GFP_NORETRY);
>>>>>> +				       __GFP_NOMEMALLOC | __GFP_NORETRY |
>>>>>> +				       __GFP_NOWARN);
>>>>>> +
>>>>>> +	if (!page)
>>>>>> +		pr_warn_ratelimited("memory balloon: memory allocation failed");
>>>>>> +
>>>>>> 	return page;
>>>>>> }
>>>>>> EXPORT_SYMBOL_GPL(balloon_page_alloc);
>>>>>=20
>>>>> Not sure if "memory balloon" is the right wording. hmmm.
>>>>>=20
>>>>> Acked-by: David Hildenbrand <david@redhat.com>
>>>>=20
>>>> Do you have a better suggestion?
>>>=20
>>> Not really - that's why I ack'ed :)
>>>=20
>>> However, thinking about it - what about moving the check + print to the
>>> caller and then using dev_warn... or sth. like simple "virtio_balloon:
>>> ..." ? You can then drop the warning for vmware balloon if you feel lik=
e
>>> not needing it.
>>=20
>> Actually, there is already a warning that is printed by the virtue_ballo=
on
>> in fill_balloon():
>>=20
>>                struct page *page =3D balloon_page_alloc();
>>=20
>>                if (!page) {
>>                        dev_info_ratelimited(&vb->vdev->dev,
>>                                             "Out of puff! Can't get %u p=
ages\n",
>>                                             VIRTIO_BALLOON_PAGES_PER_PAG=
E);
>>                        /* Sleep for at least 1/5 of a second before retr=
y. */
>>                        msleep(200);
>>                        break;
>>                }
>>=20
>> So are you ok with going back to v1?
>=20
> Whoops, I missed that - sorry - usually the warnings scream louder at me =
:D
>=20
> Yes, v1 is fine with me!

Thanks, I missed this one too. This change should prevent making users
concerned for no good reason.


