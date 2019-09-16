Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CC5DC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:50:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04E65206A4
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:50:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="cq2qh7lC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04E65206A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 915BC6B0003; Mon, 16 Sep 2019 16:50:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C6B86B0006; Mon, 16 Sep 2019 16:50:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78E5D6B0007; Mon, 16 Sep 2019 16:50:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id 4F34D6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 16:50:57 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E891C181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:50:56 +0000 (UTC)
X-FDA: 75941978112.19.place96_80ae19a52b16
X-HE-Tag: place96_80ae19a52b16
X-Filterd-Recvd-Size: 14955
Received: from nat-hk.nvidia.com (nat-hk.nvidia.com [203.18.50.4])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:50:54 +0000 (UTC)
Received: from hkpgpgate101.nvidia.com (Not Verified[10.18.92.100]) by nat-hk.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d7ff5a60000>; Tue, 17 Sep 2019 04:50:47 +0800
Received: from HKMAIL101.nvidia.com ([10.18.16.10])
  by hkpgpgate101.nvidia.com (PGP Universal service);
  Mon, 16 Sep 2019 13:50:46 -0700
X-PGP-Universal: processed;
	by hkpgpgate101.nvidia.com on Mon, 16 Sep 2019 13:50:46 -0700
Received: from HKMAIL101.nvidia.com (10.18.16.10) by HKMAIL101.nvidia.com
 (10.18.16.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 16 Sep
 2019 20:50:46 +0000
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (104.47.44.51) by
 HKMAIL101.nvidia.com (10.18.16.10) with Microsoft SMTP Server (TLS) id
 15.0.1473.3 via Frontend Transport; Mon, 16 Sep 2019 20:50:46 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=hwbINpp065yNe7lP1MzBdFm299l8PQ/bjt6M9wRvFlHR8+t75iLStmpO2unVpdA0CTzOyHU64SH43At0KEO7wXWVpgjIkpEO8H1JikLqw+L8AGeHkGP1huE2yw9b2r8u/yVDLx2R93ilkq/8gW+ebv2ihm4wpYyfWn9YQoZkRXy1UDGuSwPZJ2rWohllzTZ1CaW0Cwk+d2LCXEQenKyo/Sr71ZSY88I+IKf5b7Mh+qspYhk4BAQKqQRXNTzWGs9ak5Gpefxi2Qbr1ffLflQna/bSWBQSshwBVj1FHU49urdebW1ij1HRQ1YVWOYsbexEU29Amjj1wss11GK6mMdymA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xX6DN+khmy+x2klsziefocuOXF+U9j0aBou2z+fEOvA=;
 b=H1M2wUXA/6D5lFbI/etqV25zWT4BUWuiZXIQxord4MNTOgUrLosWwehWQGCj2LgzErRmq1+6HEN7eNQi4eLyO/Tr84U38G4gp53uSFRdEffDO2Dv9a6TorFMvYhVDx4qO3BTENWI0XZNQvPNM53rC7/2jzwZljDUX9O1Ne1s9Z4yFNO7xjrGXBTKhf+9YjWq9KOKomJDz1PpCHVO7JQvLj31JU9W/AFj722Glw1l/gFsmTf83hZSp4o8Dv13cmO1hKoduQrWeCSUCm1ECTOVZMNgiGCKLZxJ+DCpJrCust5bhctKUkRlljImHVa5UnjwSketBIyvbKEvo6Ax5G1NAQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
Received: from BYAPR12MB3015.namprd12.prod.outlook.com (20.178.55.78) by
 BYAPR12MB2773.namprd12.prod.outlook.com (20.177.126.74) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.26; Mon, 16 Sep 2019 20:50:43 +0000
Received: from BYAPR12MB3015.namprd12.prod.outlook.com
 ([fe80::2da1:b02f:cd54:eae9]) by BYAPR12MB3015.namprd12.prod.outlook.com
 ([fe80::2da1:b02f:cd54:eae9%3]) with mapi id 15.20.2263.023; Mon, 16 Sep 2019
 20:50:43 +0000
From: Nitin Gupta <nigupta@nvidia.com>
To: "rientjes@google.com" <rientjes@google.com>
CC: "keescook@chromium.org" <keescook@chromium.org>, "willy@infradead.org"
	<willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>,
	"aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org"
	<hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"cai@lca.pw" <cai@lca.pw>, "arunks@codeaurora.org" <arunks@codeaurora.org>,
	"janne.huttunen@nokia.com" <janne.huttunen@nokia.com>, "jannh@google.com"
	<jannh@google.com>, "yuzhao@google.com" <yuzhao@google.com>,
	"mhocko@suse.com" <mhocko@suse.com>, "gregkh@linuxfoundation.org"
	<gregkh@linuxfoundation.org>, "guro@fb.com" <guro@fb.com>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"khlebnikov@yandex-team.ru" <khlebnikov@yandex-team.ru>
Subject: Re: [RFC] mm: Proactive compaction
Thread-Topic: [RFC] mm: Proactive compaction
Thread-Index: AQHVVHvSPOoT6GjwikqO8JNrunJOkacu7k6AgAAJiQA=
Date: Mon, 16 Sep 2019 20:50:43 +0000
Message-ID: <4b8b0cd5d7a246e9db1e1dd9b3bae7860d7ca2c0.camel@nvidia.com>
References: <20190816214413.15006-1-nigupta@nvidia.com>
	 <alpine.DEB.2.21.1909161312050.118156@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1909161312050.118156@chino.kir.corp.google.com>
Reply-To: Nitin Gupta <nigupta@nvidia.com>
Accept-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=nigupta@nvidia.com; 
x-originating-ip: [216.228.112.21]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8547cc32-9d84-45ad-b9be-08d73ae78abc
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR12MB2773;
x-ms-traffictypediagnostic: BYAPR12MB2773:
x-ms-exchange-purlcount: 3
x-microsoft-antispam-prvs: <BYAPR12MB277323FB0F312CCDB94DA4BCD88C0@BYAPR12MB2773.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0162ACCC24
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(396003)(376002)(366004)(136003)(346002)(39860400002)(199004)(189003)(6506007)(25786009)(53936002)(6246003)(4326008)(2501003)(43066004)(186003)(7416002)(11346002)(2616005)(2906002)(256004)(14444005)(446003)(476003)(6916009)(561944003)(3846002)(6116002)(66066001)(486006)(118296001)(71190400001)(6512007)(86362001)(5640700003)(71200400001)(76176011)(2351001)(5660300002)(99286004)(6306002)(102836004)(6436002)(26005)(81166006)(81156014)(6486002)(66476007)(66446008)(316002)(3450700001)(966005)(64756008)(66556008)(8676002)(36756003)(7736002)(14454004)(76116006)(8936002)(478600001)(66946007)(91956017)(54906003)(305945005)(229853002)(1730700003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB2773;H:BYAPR12MB3015.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nvidia.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: FPaw/P196Bp+SK7wGY0QeOMog7x1Wa6abjaOcHcszkQOlSCfwLvoGQwYi2L108DMTn7Vl1s+OW2iFNNmoPCXBgX4DUUgUPmH2BPZj4Y9OBZ/+S5XESU7QQo2mtgClDeScicUfsAb5rIQnH8C4KgWJnH9wmqAp2Wi2fIZtVUki9YmdBmCW+IV/GYCUI9YAYK2O/pta098nO/8ryehXw8I7N9Coro5kqC9YRrn9AU0TjeMXSrfap6ETGJ/xeT5v4Yu+oxxteY/eg951f7vlW0JxbnGv9OoFPGJKKRVkRE5603qefRmdrggZd9M2BamwI+TJj7ATNp+yt/2N9WuOQVZMXRncPfOHOTtKYlCC3o/NdZ+/mBQKXz0i76GDt8/O0NUJuJRpDgGMSl6vEUOgIw5kzijhydwpn3HGDQdt5mh87I=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 8547cc32-9d84-45ad-b9be-08d73ae78abc
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Sep 2019 20:50:43.3506
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: dirXsy94B3nd/Q50HB7K9b3HPEm9qx+lIkb/SRyrbl+PpyehIfVIfo5G3n0mqn3RZySDD+t1D0lvTo2TRPe6uA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB2773
X-OriginatorOrg: Nvidia.com
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <E954B80E73C5D94297971003F985BD19@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568667047; bh=xX6DN+khmy+x2klsziefocuOXF+U9j0aBou2z+fEOvA=;
	h=X-PGP-Universal:ARC-Seal:ARC-Message-Signature:
	 ARC-Authentication-Results:From:To:CC:Subject:Thread-Topic:
	 Thread-Index:Date:Message-ID:References:In-Reply-To:Reply-To:
	 Accept-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:
	 authentication-results:x-originating-ip:x-ms-publictraffictype:
	 x-ms-office365-filtering-correlation-id:x-microsoft-antispam:
	 x-ms-traffictypediagnostic:x-ms-exchange-purlcount:
	 x-microsoft-antispam-prvs:x-ms-oob-tlc-oobclassifiers:
	 x-forefront-prvs:x-forefront-antispam-report:received-spf:
	 x-ms-exchange-senderadcheck:x-microsoft-antispam-message-info:
	 x-ms-exchange-transport-forked:MIME-Version:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-originalarrivaltime:
	 X-MS-Exchange-CrossTenant-fromentityheader:
	 X-MS-Exchange-CrossTenant-id:X-MS-Exchange-CrossTenant-mailboxtype:
	 X-MS-Exchange-CrossTenant-userprincipalname:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped:X-OriginatorOrg:
	 Content-Language:Content-Type:Content-ID:
	 Content-Transfer-Encoding;
	b=cq2qh7lChDAPIvjKtz3OiKdj/W8v9bh8c0kvq3MT9og3/JEAQp1NyE4NYnzacNCUn
	 yIyH75A8vxkepBo3G+am4XQAnuX/B5atA/v37WXE6CnYlYSG0ewjudOZgTRP9TN18t
	 DmjM28sRyYnDV0+h+WHZ0KhS48MGe9bjAy0p4Y8McriDHu4CIVbMfyC6yvaMFV1+hy
	 iiYcKzdzbnLx5O5te80cbARipSZJZ6f7m7iXfP0Z2Zt+z1KEG2pd3teO66Z8WdqItK
	 9WLbmLoLEesldw6Ti+ojEolBUoBdDY0OVkqRRD493mnHIH0Ym/xlyHKDyOpOZq1NL0
	 8icgFeKdy4CIQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA5LTE2IGF0IDEzOjE2IC0wNzAwLCBEYXZpZCBSaWVudGplcyB3cm90ZToN
Cj4gT24gRnJpLCAxNiBBdWcgMjAxOSwgTml0aW4gR3VwdGEgd3JvdGU6DQo+IA0KPiA+IEZvciBz
b21lIGFwcGxpY2F0aW9ucyB3ZSBuZWVkIHRvIGFsbG9jYXRlIGFsbW9zdCBhbGwgbWVtb3J5IGFz
DQo+ID4gaHVnZXBhZ2VzLiBIb3dldmVyLCBvbiBhIHJ1bm5pbmcgc3lzdGVtLCBoaWdoZXIgb3Jk
ZXIgYWxsb2NhdGlvbnMgY2FuDQo+ID4gZmFpbCBpZiB0aGUgbWVtb3J5IGlzIGZyYWdtZW50ZWQu
IExpbnV4IGtlcm5lbCBjdXJyZW50bHkgZG9lcw0KPiA+IG9uLWRlbWFuZCBjb21wYWN0aW9uIGFz
IHdlIHJlcXVlc3QgbW9yZSBodWdlcGFnZXMgYnV0IHRoaXMgc3R5bGUgb2YNCj4gPiBjb21wYWN0
aW9uIGluY3VycyB2ZXJ5IGhpZ2ggbGF0ZW5jeS4gRXhwZXJpbWVudHMgd2l0aCBvbmUtdGltZSBm
dWxsDQo+ID4gbWVtb3J5IGNvbXBhY3Rpb24gKGZvbGxvd2VkIGJ5IGh1Z2VwYWdlIGFsbG9jYXRp
b25zKSBzaG93cyB0aGF0IGtlcm5lbA0KPiA+IGlzIGFibGUgdG8gcmVzdG9yZSBhIGhpZ2hseSBm
cmFnbWVudGVkIG1lbW9yeSBzdGF0ZSB0byBhIGZhaXJseQ0KPiA+IGNvbXBhY3RlZCBtZW1vcnkg
c3RhdGUgd2l0aGluIDwxIHNlYyBmb3IgYSAzMkcgc3lzdGVtLiBTdWNoIGRhdGENCj4gPiBzdWdn
ZXN0cyB0aGF0IGEgbW9yZSBwcm9hY3RpdmUgY29tcGFjdGlvbiBjYW4gaGVscCB1cyBhbGxvY2F0
ZSBhIGxhcmdlDQo+ID4gZnJhY3Rpb24gb2YgbWVtb3J5IGFzIGh1Z2VwYWdlcyBrZWVwaW5nIGFs
bG9jYXRpb24gbGF0ZW5jaWVzIGxvdy4NCj4gPiANCj4gPiBGb3IgYSBtb3JlIHByb2FjdGl2ZSBj
b21wYWN0aW9uLCB0aGUgYXBwcm9hY2ggdGFrZW4gaGVyZSBpcyB0byBkZWZpbmUNCj4gPiBwZXIg
cGFnZS1vcmRlciBleHRlcm5hbCBmcmFnbWVudGF0aW9uIHRocmVzaG9sZHMgYW5kIGxldCBrY29t
cGFjdGQNCj4gPiB0aHJlYWRzIGFjdCBvbiB0aGVzZSB0aHJlc2hvbGRzLg0KPiA+IA0KPiA+IFRo
ZSBsb3cgYW5kIGhpZ2ggdGhyZXNob2xkcyBhcmUgZGVmaW5lZCBwZXIgcGFnZS1vcmRlciBhbmQg
ZXhwb3NlZA0KPiA+IHRocm91Z2ggc3lzZnM6DQo+ID4gDQo+ID4gICAvc3lzL2tlcm5lbC9tbS9j
b21wYWN0aW9uL29yZGVyLVsxLi5NQVhfT1JERVJdL2V4dGZyYWdfe2xvdyxoaWdofQ0KPiA+IA0K
PiA+IFBlci1ub2RlIGtjb21wYWN0ZCB0aHJlYWQgaXMgd29rZW4gdXAgZXZlcnkgZmV3IHNlY29u
ZHMgdG8gY2hlY2sgaWYNCj4gPiBhbnkgem9uZSBvbiBpdHMgbm9kZSBoYXMgZXh0ZnJhZyBhYm92
ZSB0aGUgZXh0ZnJhZ19oaWdoIHRocmVzaG9sZCBmb3INCj4gPiBhbnkgb3JkZXIsIGluIHdoaWNo
IGNhc2UgdGhlIHRocmVhZCBzdGFydHMgY29tcGFjdGlvbiBpbiB0aGUgYmFja2dyb25kDQo+ID4g
dGlsbCBhbGwgem9uZXMgYXJlIGJlbG93IGV4dGZyYWdfbG93IGxldmVsIGZvciBhbGwgb3JkZXJz
LiBCeSBkZWZhdWx0DQo+ID4gYm90aCB0aGVzZSB0aHJlc29sZHMgYXJlIHNldCB0byAxMDAgZm9y
IGFsbCBvcmRlcnMgd2hpY2ggZXNzZW50aWFsbHkNCj4gPiBkaXNhYmxlcyBrY29tcGFjdGQuDQo+
ID4gDQo+ID4gVG8gYXZvaWQgd2FzdGluZyBDUFUgY3ljbGVzIHdoZW4gY29tcGFjdGlvbiBjYW5u
b3QgaGVscCwgc3VjaCBhcyB3aGVuDQo+ID4gbWVtb3J5IGlzIGZ1bGwsIHdlIGNoZWNrIGJvdGgs
IGV4dGZyYWcgPiBleHRmcmFnX2hpZ2ggYW5kDQo+ID4gY29tcGFjdGlvbl9zdWl0YWJsZSh6b25l
KS4gVGhpcyBhbGxvd3Mga2NvbWFwY3RkIHRocmVhZCB0byBzdGF5cyBpbmFjdGl2ZQ0KPiA+IGV2
ZW4gaWYgZXh0ZnJhZyB0aHJlc2hvbGRzIGFyZSBub3QgbWV0Lg0KPiA+IA0KPiA+IFRoaXMgcGF0
Y2ggaXMgbGFyZ2VseSBiYXNlZCBvbiBpZGVhcyBmcm9tIE1pY2hhbCBIb2NrbyBwb3N0ZWQgaGVy
ZToNCj4gPiBodHRwczovL2xvcmUua2VybmVsLm9yZy9saW51eC1tbS8yMDE2MTIzMDEzMTQxMi5H
STEzMzAxQGRoY3AyMi5zdXNlLmN6Lw0KPiA+IA0KPiA+IFRlc3RpbmcgZG9uZSAob24geDg2KToN
Cj4gPiAgLSBTZXQgL3N5cy9rZXJuZWwvbW0vY29tcGFjdGlvbi9vcmRlci05L2V4dGZyYWdfe2xv
dyxoaWdofSA9IHsyNSwgMzB9DQo+ID4gIHJlc3BlY3RpdmVseS4NCj4gPiAgLSBVc2UgYSB0ZXN0
IHByb2dyYW0gdG8gZnJhZ21lbnQgbWVtb3J5OiB0aGUgcHJvZ3JhbSBhbGxvY2F0ZXMgYWxsIG1l
bW9yeQ0KPiA+ICBhbmQgdGhlbiBmb3IgZWFjaCAyTSBhbGlnbmVkIHNlY3Rpb24sIGZyZWVzIDMv
NCBvZiBiYXNlIHBhZ2VzIHVzaW5nDQo+ID4gIG11bm1hcC4NCj4gPiAgLSBrY29tcGFjdGQwIGRl
dGVjdHMgZnJhZ21lbnRhdGlvbiBmb3Igb3JkZXItOSA+IGV4dGZyYWdfaGlnaCBhbmQgc3RhcnRz
DQo+ID4gIGNvbXBhY3Rpb24gdGlsbCBleHRmcmFnIDwgZXh0ZnJhZ19sb3cgZm9yIG9yZGVyLTku
DQo+ID4gDQo+ID4gVGhlIHBhdGNoIGhhcyBwbGVudHkgb2Ygcm91Z2ggZWRnZXMgYnV0IHBvc3Rp
bmcgaXQgZWFybHkgdG8gc2VlIGlmIEknbQ0KPiA+IGdvaW5nIGluIHRoZSByaWdodCBkaXJlY3Rp
b24gYW5kIHRvIGdldCBzb21lIGVhcmx5IGZlZWRiYWNrLg0KPiA+IA0KPiANCj4gSXMgdGhlcmUg
YW4gdXBkYXRlIHRvIHRoaXMgcHJvcG9zYWwgb3Igbm9uLVJGQyBwYXRjaCB0aGF0IGhhcyBiZWVu
IHBvc3RlZCANCj4gZm9yIHByb2FjdGl2ZSBjb21wYWN0aW9uPw0KPiANCj4gV2UndmUgaGFkIGdv
b2Qgc3VjY2VzcyB3aXRoIHBlcmlvZGljYWxseSBjb21wYWN0aW5nIG1lbW9yeSBvbiBhIHJlZ3Vs
YXIgDQo+IGNhZGVuY2Ugb24gc3lzdGVtcyB3aXRoIGh1Z2VwYWdlcyBlbmFibGVkLiAgVGhlIGNh
ZGVuY2UgaXRzZWxmIGlzIGRlZmluZWQgDQo+IGJ5IHRoZSBhZG1pbiBidXQgaXQgY2F1c2VzIGto
dWdlcGFnZWRbKl0gdG8gcGVyaW9kaWNhbGx5IHdha2V1cCBhbmQgaW52b2tlIA0KPiBjb21wYWN0
aW9uIGluIGFuIGF0dGVtcHQgdG8ga2VlcCB6b25lcyBhcyBkZWZyYWdtZW50ZWQgYXMgcG9zc2li
bGUgDQo+IChwZXJoYXBzIG1vcmUgInByb2FjdGl2ZSIgdGhhbiB3aGF0IGlzIHByb3Bvc2VkIGhl
cmUgaW4gYW4gYXR0ZW1wdCB0byBrZWVwIA0KPiBhbGwgbWVtb3J5IGFzIHVuZnJhZ21lbnRlZCBh
cyBwb3NzaWJsZSByZWdhcmRsZXNzIG9mIGV4dGZyYWcgdGhyZXNob2xkcykuICANCj4gSXQgYWxz
byBhdm9pZHMgY29ybmVyLWNhc2VzIHdoZXJlIGtjb21wYWN0ZCBjb3VsZCBiZWNvbWUgbW9yZSBl
eHBlbnNpdmUgDQo+IHRoYW4gd2hhdCBpcyBhbnRpY2lwYXRlZCBiZWNhdXNlIGl0IGlzIHVuc3Vj
Y2Vzc2Z1bCBhdCBjb21wYWN0aW5nIG1lbW9yeSANCj4geWV0IHRoZSBleHRmcmFnIHRocmVzaG9s
ZCBpcyBzdGlsbCBleGNlZWRlZC4NCj4gDQo+ICBbKl0gS2h1Z2VwYWdlZCBpbnN0ZWFkIG9mIGtj
b21wYWN0ZCBvbmx5IGJlY2F1c2UgdGhpcyBpcyBvbmx5IGVuYWJsZWQNCj4gICAgICBmb3Igc3lz
dGVtcyB3aGVyZSB0cmFuc3BhcmVudCBodWdlcGFnZXMgYXJlIGVuYWJsZWQsIHByb2JhYmx5IGJl
dHRlcg0KPiAgICAgIG9mZiBpbiBrY29tcGFjdGQgdG8gYXZvaWQgZHVwbGljYXRpbmcgd29yayBi
ZXR3ZWVuIHR3byBrdGhyZWFkcyBpZg0KPiAgICAgIHRoZXJlIGlzIGFscmVhZHkgYSBuZWVkIGZv
ciBiYWNrZ3JvdW5kIGNvbXBhY3Rpb24uDQo+IA0KDQoNCkRpc2N1c3Npb24gb24gdGhpcyBSRkMg
cGF0Y2ggcmV2b2x2ZWQgYXJvdW5kIHRoZSBpc3N1ZSBvZiBleHBvc2luZyB0b28NCm1hbnkgdHVu
YWJsZXMgKHBlci1ub2RlLCBwZXItb3JkZXIsIFtsb3ctaGlnaF0gZXh0ZnJhZyB0aHJlc2hvbGRz
KS4gSXQNCndhcyBzb3J0LW9mIGNvbmNsdWRlZCB0aGF0IG5vIGFkbWluIHdpbGwgZ2V0IHRoZXNl
IHR1bmFibGVzIHJpZ2h0IGZvcg0KYSB2YXJpZXR5IG9mIHdvcmtsb2Fkcy4NCg0KVG8gZWxpbWlu
YXRlIHRoZSBuZWVkIGZvciB0dW5hYmxlcywgSSBwcm9wb3NlZCBhbm90aGVyIHBhdGNoOg0KDQpo
dHRwczovL3BhdGNod29yay5rZXJuZWwub3JnL3BhdGNoLzExMTQwMDY3Lw0KDQp3aGljaCBkb2Vz
IG5vdCBhZGQgYW55IHR1bmFibGVzIGJ1dCBleHRlbmRzIGFuZCBleHBvcnRzIGFuIGV4aXN0aW5n
DQpmdW5jdGlvbiAoY29tcGFjdF96b25lX29yZGVyKS4gSW4gc3VtbWFyeSwgdGhpcyBuZXcgcGF0
Y2ggYWRkcyBhDQpjYWxsYmFjayBmdW5jdGlvbiB3aGljaCBhbGxvd3MgYW55IGRyaXZlciB0byBp
bXBsZW1lbnQgYWQtaG9jDQpjb21wYWN0aW9uIHBvbGljaWVzLiBUaGVyZSBpcyBhbHNvIGEgc2Ft
cGxlIGRyaXZlciB3aGljaCBtYWtlcyB1c2UNCm9mIHRoaXMgaW50ZXJmYWNlIHRvIGtlZXAgaHVn
ZXBhZ2UgZXh0ZXJuYWwgZnJhZ21lbnRhdGlvbiB3aXRoaW4NCnNwZWNpZmllZCByYW5nZSAoZXhw
b3NlZCB0aHJvdWdoIGRlYnVnZnMpOg0KDQpodHRwczovL2dpdGxhYi5jb20vbmlndXB0YS9saW51
eC9zbmlwcGV0cy8xODk0MTYxDQoNCi1OaXRpbg0KDQo=

