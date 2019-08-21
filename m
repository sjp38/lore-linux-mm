Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 112F2C41514
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8BA922D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:59:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="hjH5olWM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8BA922D6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A39E6B0290; Wed, 21 Aug 2019 14:59:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 655566B0291; Wed, 21 Aug 2019 14:59:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56A4F6B0292; Wed, 21 Aug 2019 14:59:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8866B0290
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:40 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DDBC98248AAC
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:59:39 +0000 (UTC)
X-FDA: 75847348878.29.son20_8e79c767fc821
X-HE-Tag: son20_8e79c767fc821
X-Filterd-Recvd-Size: 7923
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780077.outbound.protection.outlook.com [40.107.78.77])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:59:38 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=afE7aTivTngYiuZmjhxanqgHBPbv1fuKmguqa3Qw4QLVRkmBhRQWqfJxyLgUpdmjM/2SDZWogqscDv47OChs7JnSWFj6d+F23wlF1BxpHGXHARzrM/fOTrXVUNypseP3Yky9ScdYLyrww625uOcKOP5brI4Avy/IeWlwO0qloVdC06SIqve4mPT/NbOwY6L9HjoqJuvHLoCrtA2M6YL7qhOfAHoZM5He/O7oT4Q50L/9NYvKjfUW7Qg5kVbTILMZk0fgozAc3K/q5KvrlRG5A2yrdLOzr59YGDz2cWJItsZeHYPSvA9MzT4xSKApcna79RdCrrn3zjdQCnDadPkXFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bpsejHAG8GNGL6TGAsejnB71BUzlaZtpQTS4DQPTPrU=;
 b=GRks0D3aXBQHvuxOeEJvnVnJUDr5AI3sMTocq4j0QShZWMdW9ISIJIWrHJs1wu15uZxKxxq7J5MRL6NSquhgo1w98APf1ZLXnSPnGlBZFfk9l2c3OCQGDKT5NYVAQ/iIK/aC7cieU9Qi4+ijO6qKqbd93hmsGxSoGzi4yktbaNzcQgBkkHW4C+RRqvtUK6Cnaa4YyQsm0eU27Rs6seBVXnFhY0aS8QuP4urKwKqrjalkCbV5+6zaPce8Yw8gzIDQU0BADtwGiwvSBygkAHYp2BMPieKJ3LseMKLPSKOajmszid6E3m7HQEC/lbfjxknc8r46zZpe82+G6Ie+D1NL4Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=vmware.com; dmarc=pass action=none header.from=vmware.com;
 dkim=pass header.d=vmware.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bpsejHAG8GNGL6TGAsejnB71BUzlaZtpQTS4DQPTPrU=;
 b=hjH5olWMCW3ei+2a1+oObp84YwFGQEETXo6ZqpXOwSwKslhlxQNroBkXezpzfRyYF/wZjaHtyLzuvAz5uFEJhXGomHoF57FskxN7qm0MdcNlBrRXcIIGhzQSj73xMfFFgJOJxg/afsf09d/w6F6hm7sEFSmU5ZUI+IgLqPmK8Ek=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5687.namprd05.prod.outlook.com (20.178.1.220) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2199.11; Wed, 21 Aug 2019 18:59:33 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::1541:ed53:784a:6376]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::1541:ed53:784a:6376%5]) with mapi id 15.20.2199.011; Wed, 21 Aug 2019
 18:59:33 +0000
From: Nadav Amit <namit@vmware.com>
To: David Hildenbrand <david@redhat.com>
CC: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm/balloon_compaction: Informative allocation warnings
Thread-Topic: [PATCH v2] mm/balloon_compaction: Informative allocation
 warnings
Thread-Index: AQHVWEJHWn7VmeZ5cEugJmetWObq/6cF9CyAgAAAcQA=
Date: Wed, 21 Aug 2019 18:59:32 +0000
Message-ID: <4E10A342-9A51-4C1F-8E5A-8005AACEF4CE@vmware.com>
References: <20190821094159.40795-1-namit@vmware.com>
 <75ff92c2-7ae2-c4a6-cd1f-44741e29d20e@redhat.com>
In-Reply-To: <75ff92c2-7ae2-c4a6-cd1f-44741e29d20e@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e24b47ef-064e-4344-b982-08d72669b408
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR05MB5687;
x-ms-traffictypediagnostic: BYAPR05MB5687:
x-microsoft-antispam-prvs:
 <BYAPR05MB56876D6E8010ACA7769026F7D0AA0@BYAPR05MB5687.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1388;
x-forefront-prvs: 0136C1DDA4
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(346002)(136003)(366004)(396003)(376002)(199004)(189003)(6486002)(66946007)(76116006)(6116002)(54906003)(3846002)(66446008)(64756008)(66556008)(66476007)(478600001)(6246003)(25786009)(6512007)(6436002)(14454004)(33656002)(4326008)(66066001)(229853002)(6916009)(53936002)(8936002)(446003)(81156014)(14444005)(36756003)(256004)(186003)(76176011)(71190400001)(81166006)(305945005)(5660300002)(86362001)(102836004)(476003)(7736002)(53546011)(6506007)(2616005)(486006)(8676002)(2906002)(316002)(71200400001)(99286004)(26005)(11346002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5687;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 gTysi6YqWq1QF4DlvSS9bQZkK3D7e/pZiflpC+vAgruXNsTCPK6O+lhTRBb2wj51fv6cCsWU39v2dVhdKLUCY/3ToVE+1amAU4a+DPL34eIrJLVfB+9Jdm1X78Fx0Cfef+D5bVn6A8WWZVJisgzU3sZwZ5feYnL5x1hwHsYsyXXTjVGkcqG5ZmwT66j4LM81gsTd1TivZWr9/mbmNZxmr3dEy5Zii7/RS2nYR3M4sdPd4D7HsdwCfLVpcBrPf7BK1MBfanHp50q85UhERneNcjKuUrVXMDRVzvJUnNgKyifYLIIOMe/vYv15Cdu2vzu5gXKTcXH2QaEelXIUnOzzoAykyUGWq9A1OQI33Jp7mTrwf0f2ysMIgfHR9TfG7lIYohLbhlrTbWPO1i9I8OfxxF1UvuqIurS9RzaNLqoZ8KU=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3A38FA3954F90E49AB4A1D4968549FAF@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e24b47ef-064e-4344-b982-08d72669b408
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Aug 2019 18:59:32.8997
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: zhohh2xN6E6IypEHFzk2CM/yb7C76yfHc6QZY2s9U68v5PYGF5syks0tlsMEYjXzz1ewoBxE7RV8KQH3AH9hIg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5687
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Aug 21, 2019, at 11:57 AM, David Hildenbrand <david@redhat.com> wrote:
>=20
> On 21.08.19 11:41, Nadav Amit wrote:
>> There is no reason to print generic warnings when balloon memory
>> allocation fails, as failures are expected and can be handled
>> gracefully. Since VMware balloon now uses balloon-compaction
>> infrastructure, and suppressed these warnings before, it is also
>> beneficial to suppress these warnings to keep the same behavior that the
>> balloon had before.
>>=20
>> Since such warnings can still be useful to indicate that the balloon is
>> over-inflated, print more informative and less frightening warning if
>> allocation fails instead.
>>=20
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: Jason Wang <jasowang@redhat.com>
>> Signed-off-by: Nadav Amit <namit@vmware.com>
>>=20
>> ---
>>=20
>> v1->v2:
>>  * Print informative warnings instead suppressing [David]
>> ---
>> mm/balloon_compaction.c | 7 ++++++-
>> 1 file changed, 6 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
>> index 798275a51887..0c1d1f7689f0 100644
>> --- a/mm/balloon_compaction.c
>> +++ b/mm/balloon_compaction.c
>> @@ -124,7 +124,12 @@ EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
>> struct page *balloon_page_alloc(void)
>> {
>> 	struct page *page =3D alloc_page(balloon_mapping_gfp_mask() |
>> -				       __GFP_NOMEMALLOC | __GFP_NORETRY);
>> +				       __GFP_NOMEMALLOC | __GFP_NORETRY |
>> +				       __GFP_NOWARN);
>> +
>> +	if (!page)
>> +		pr_warn_ratelimited("memory balloon: memory allocation failed");
>> +
>> 	return page;
>> }
>> EXPORT_SYMBOL_GPL(balloon_page_alloc);
>=20
> Not sure if "memory balloon" is the right wording. hmmm.
>=20
> Acked-by: David Hildenbrand <david@redhat.com>

Do you have a better suggestion?


