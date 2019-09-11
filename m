Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 377DDC49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 22:33:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEC2920872
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 22:33:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="fMoKpGHh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEC2920872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59D3C6B0289; Wed, 11 Sep 2019 18:33:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 526B56B028A; Wed, 11 Sep 2019 18:33:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C5A16B028B; Wed, 11 Sep 2019 18:33:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0004.hostedemail.com [216.40.44.4])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7976B0289
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 18:33:49 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 793D21E088
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:33:48 +0000 (UTC)
X-FDA: 75924093336.13.cork60_21004b7d59b07
X-HE-Tag: cork60_21004b7d59b07
X-Filterd-Recvd-Size: 21768
Received: from nat-hk.nvidia.com (nat-hk.nvidia.com [203.18.50.4])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:33:46 +0000 (UTC)
Received: from hkpgpgate102.nvidia.com (Not Verified[10.18.92.77]) by nat-hk.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d7976470000>; Thu, 12 Sep 2019 06:33:43 +0800
Received: from HKMAIL104.nvidia.com ([10.18.16.13])
  by hkpgpgate102.nvidia.com (PGP Universal service);
  Wed, 11 Sep 2019 15:33:43 -0700
X-PGP-Universal: processed;
	by hkpgpgate102.nvidia.com on Wed, 11 Sep 2019 15:33:43 -0700
Received: from HKMAIL103.nvidia.com (10.18.16.12) by HKMAIL104.nvidia.com
 (10.18.16.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 11 Sep
 2019 22:33:42 +0000
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (104.47.33.53) by
 HKMAIL103.nvidia.com (10.18.16.12) with Microsoft SMTP Server (TLS) id
 15.0.1473.3 via Frontend Transport; Wed, 11 Sep 2019 22:33:41 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Kv9LKJ3+ZsAyIrx7rkApl2rlSI+ESXx8Mi4F0/CPF49qELRiop5rfLENCC7L6kxT6SDmqpTJ8g11x6IX4/6GdslhLoDqqWVW1/S2Jfk9dk1W8Hrftjz11khqDMalgvoyWL2tij6sp/h7mfaO8Bzmgocf9U0QMbjisXZAM8S6MjCgFANKd4Vz6YETD84KXbQv8g5wrEN4lwIHPzzEPz3H+G3VpXvJynojWaLskTe+SXkLCzdTwoOIy0FxrYxnu2Tt1GnKu880Y2ht34awgjGJ/gAC9nBShZiHVHAP74OYacWmFBLzrje2dXoTdex1a7EBQaloaUpdv9LcUqFnVgn9EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9BEjIRjWN3+8HC1nAeO7NiRniOuD7ywF8Ipa3IyMtbI=;
 b=TC8CSrokoiKvl8yJCK40qo3WhCs31jwGmTzotjrZTOQo+r9qjmaptgjbhdUCdpLsZ/aHEDqOhPH+Mys3fAiKJQole/cYrS06MqdWaUxjQ2Cv0MM3CejUNBCr+D4NLzpdtkDWqvUNfm0M3P7sfTwYRLqJHMOrq9obNjvNXBiuXmemmChfYqVeeQMbqLTVECK5ZNFXyYBWpkStVZ0Pqsw+OUV4udGe7cu+Y9B7I6N4s0aetB4SDAk4NlrInR2Gvm9yftpgsav9kO3kO+MXPVTsML37XWIfA7SaQEme4Qi68Bpv2qpOg8YnSvtLypKpnHl3/guKihsXqK5izPvme3U8DA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
Received: from MN2PR12MB3022.namprd12.prod.outlook.com (20.178.243.160) by
 MN2PR12MB3856.namprd12.prod.outlook.com (10.255.237.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.18; Wed, 11 Sep 2019 22:33:39 +0000
Received: from MN2PR12MB3022.namprd12.prod.outlook.com
 ([fe80::fd61:50ed:5466:1285]) by MN2PR12MB3022.namprd12.prod.outlook.com
 ([fe80::fd61:50ed:5466:1285%7]) with mapi id 15.20.2241.018; Wed, 11 Sep 2019
 22:33:39 +0000
From: Nitin Gupta <nigupta@nvidia.com>
To: "mhocko@kernel.org" <mhocko@kernel.org>
CC: "willy@infradead.org" <willy@infradead.org>, "allison@lohutok.net"
	<allison@lohutok.net>, "vbabka@suse.cz" <vbabka@suse.cz>,
	"aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "tglx@linutronix.de"
	<tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cai@lca.pw"
	<cai@lca.pw>, "arunks@codeaurora.org" <arunks@codeaurora.org>,
	"yuzhao@google.com" <yuzhao@google.com>, "richard.weiyang@gmail.com"
	<richard.weiyang@gmail.com>, "mgorman@techsingularity.net"
	<mgorman@techsingularity.net>, "khalid.aziz@oracle.com"
	<khalid.aziz@oracle.com>, "dan.j.williams@intel.com"
	<dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: Add callback for defining compaction completion
Thread-Topic: [PATCH] mm: Add callback for defining compaction completion
Thread-Index: AQHVaBN89sjqlPYaX0aecSzy09g86KclWdWAgAATpPCAAJtVAIABCOSA
Date: Wed, 11 Sep 2019 22:33:39 +0000
Message-ID: <4ba8a6810cb481204deae4a7171dded1d8b5e736.camel@nvidia.com>
References: <20190910200756.7143-1-nigupta@nvidia.com>
	 <20190910201905.GG4023@dhcp22.suse.cz>
	 <MN2PR12MB30229414332206E25B9F3B8BD8B60@MN2PR12MB3022.namprd12.prod.outlook.com>
	 <20190911064520.GI4023@dhcp22.suse.cz>
In-Reply-To: <20190911064520.GI4023@dhcp22.suse.cz>
Reply-To: Nitin Gupta <nigupta@nvidia.com>
Accept-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=nigupta@nvidia.com; 
x-originating-ip: [216.228.112.21]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: aa64b668-c451-4831-565c-08d7370817aa
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MN2PR12MB3856;
x-ms-traffictypediagnostic: MN2PR12MB3856:
x-ms-exchange-purlcount: 2
x-microsoft-antispam-prvs: <MN2PR12MB38562E4D9918DDA588ABC839D8B10@MN2PR12MB3856.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0157DEB61B
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(136003)(39860400002)(346002)(376002)(396003)(366004)(199004)(189003)(54534003)(71190400001)(71200400001)(2616005)(76176011)(486006)(8676002)(6506007)(305945005)(186003)(43066004)(476003)(26005)(25786009)(53936002)(446003)(7416002)(5660300002)(118296001)(102836004)(7736002)(99286004)(2501003)(76116006)(91956017)(6436002)(2906002)(6916009)(86362001)(6512007)(6486002)(3450700001)(6306002)(66446008)(66476007)(66556008)(11346002)(64756008)(66946007)(229853002)(66066001)(6246003)(5640700003)(14444005)(6116002)(966005)(316002)(14454004)(8936002)(256004)(3846002)(81156014)(1730700003)(81166006)(54906003)(478600001)(36756003)(2351001)(4326008);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR12MB3856;H:MN2PR12MB3022.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nvidia.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 21Imp5o4X2P/K1j8T/t6fwg+zITgzxqCqu+9h8q7EonhJSuJEJyX8PDYkCcTdHHq/YLrFmfcqtrO7SiOVvpJ0gbzHQe+wUCzj9xHZt6EZ6ZkV+LHFim0XBXfHK7tZ94/hbdABXu5ccTEFvYBTYOM2vVdtj8Kya6oZu4rVs3dHM5xrgGMNpx07LPmfStSnETQo+zTHYDn3lhSQfbfQx1CAu9o+1WvxXpJl0ullGrcNMtWI5zzJFZHkdBLVcJ+gvTpjjD3e5e0rGDLpPPcy4qTG053li+d1ckhVRkj62EkFUMyaDsyPg6pE/QfiHRQZu+Z1AAfR274ucCz/D+r3MW4hQv3aD78m6lYn1OcqbSghtocEghBz0cubKh7gFQXTLia5k+zRoGJiT1sbKpR1C1u83p4zJIhCzboTQHd+1cnXuU=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: aa64b668-c451-4831-565c-08d7370817aa
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Sep 2019 22:33:39.1120
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: TFadeey83bZm0IwYgTMczTPUbndi0yJ+MYZ4IKX4BryoK5xXjx7YGjicOD0axv1VDufSX6uPIUH5mWPMa54IYA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR12MB3856
X-OriginatorOrg: Nvidia.com
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <49C4494AB88F5648864CB41499EDDB6B@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568241223; bh=9BEjIRjWN3+8HC1nAeO7NiRniOuD7ywF8Ipa3IyMtbI=;
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
	b=fMoKpGHhHT/Mo/7B7rQ/kPNdwWVnkrNmQ8hYtzdj7FRBBjTTiXdHnsBa4C2OceoXY
	 hqX/9b+oJh9OUHjUNtt9y7KZtkMqwzmERciGS7KaeVULv6mfq06IIyghQ1BjVAiA3G
	 d7UaX3nlXdWTltVVKD0J9OpBcyfF8iZB4WJbKSL3oOMxMXF5+aPy6MstQqMH0AezKS
	 iQzxVmIEb2TDFH2xLsfnlP2tkUHtbW+oMxlragpfWIy9WJUrk9l56pzd38bxxpDPY8
	 qzKEd4tiidVb946zvn7S/d3/vvtnXe56c/DxVai1Uu6xVHZXUkCQ9d9JXRdskexoyN
	 3tTeV4p1V8SAw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTA5LTExIGF0IDA4OjQ1ICswMjAwLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+
IE9uIFR1ZSAxMC0wOS0xOSAyMjoyNzo1MywgTml0aW4gR3VwdGEgd3JvdGU6DQo+IFsuLi5dDQo+
ID4gPiBPbiBUdWUgMTAtMDktMTkgMTM6MDc6MzIsIE5pdGluIEd1cHRhIHdyb3RlOg0KPiA+ID4g
PiBGb3Igc29tZSBhcHBsaWNhdGlvbnMgd2UgbmVlZCB0byBhbGxvY2F0ZSBhbG1vc3QgYWxsIG1l
bW9yeSBhcw0KPiA+ID4gPiBodWdlcGFnZXMuDQo+ID4gPiA+IEhvd2V2ZXIsIG9uIGEgcnVubmlu
ZyBzeXN0ZW0sIGhpZ2hlciBvcmRlciBhbGxvY2F0aW9ucyBjYW4gZmFpbCBpZiB0aGUNCj4gPiA+
ID4gbWVtb3J5IGlzIGZyYWdtZW50ZWQuIExpbnV4IGtlcm5lbCBjdXJyZW50bHkgZG9lcyBvbi1k
ZW1hbmQNCj4gPiA+ID4gY29tcGFjdGlvbg0KPiA+ID4gPiBhcyB3ZSByZXF1ZXN0IG1vcmUgaHVn
ZXBhZ2VzIGJ1dCB0aGlzIHN0eWxlIG9mIGNvbXBhY3Rpb24gaW5jdXJzIHZlcnkNCj4gPiA+ID4g
aGlnaCBsYXRlbmN5LiBFeHBlcmltZW50cyB3aXRoIG9uZS10aW1lIGZ1bGwgbWVtb3J5IGNvbXBh
Y3Rpb24NCj4gPiA+ID4gKGZvbGxvd2VkIGJ5IGh1Z2VwYWdlIGFsbG9jYXRpb25zKSBzaG93cyB0
aGF0IGtlcm5lbCBpcyBhYmxlIHRvDQo+ID4gPiA+IHJlc3RvcmUgYSBoaWdobHkgZnJhZ21lbnRl
ZCBtZW1vcnkgc3RhdGUgdG8gYSBmYWlybHkgY29tcGFjdGVkIG1lbW9yeQ0KPiA+ID4gPiBzdGF0
ZSB3aXRoaW4gPDEgc2VjIGZvciBhIDMyRyBzeXN0ZW0uIFN1Y2ggZGF0YSBzdWdnZXN0cyB0aGF0
IGEgbW9yZQ0KPiA+ID4gPiBwcm9hY3RpdmUgY29tcGFjdGlvbiBjYW4gaGVscCB1cyBhbGxvY2F0
ZSBhIGxhcmdlIGZyYWN0aW9uIG9mIG1lbW9yeQ0KPiA+ID4gPiBhcyBodWdlcGFnZXMga2VlcGlu
ZyBhbGxvY2F0aW9uIGxhdGVuY2llcyBsb3cuDQo+ID4gPiA+IA0KPiA+ID4gPiBJbiBnZW5lcmFs
LCBjb21wYWN0aW9uIGNhbiBpbnRyb2R1Y2UgdW5leHBlY3RlZCBsYXRlbmNpZXMgZm9yDQo+ID4g
PiA+IGFwcGxpY2F0aW9ucyB0aGF0IGRvbid0IGV2ZW4gaGF2ZSBzdHJvbmcgcmVxdWlyZW1lbnRz
IGZvciBjb250aWd1b3VzDQo+ID4gPiA+IGFsbG9jYXRpb25zLg0KPiANCj4gQ291bGQgeW91IGV4
cGFuZCBvbiB0aGlzIGEgYml0IHBsZWFzZT8gR2ZwIGZsYWdzIGFsbG93IHRvIGV4cHJlc3MgaG93
DQo+IG11Y2ggdGhlIGFsbG9jYXRvciB0cnkgYW5kIGNvbXBhY3QgZm9yIGEgaGlnaCBvcmRlciBh
bGxvY2F0aW9ucy4gSHVnZXRsYg0KPiBhbGxvY2F0aW9ucyB0ZW5kIHRvIHJlcXVpcmUgcmV0cnlp
bmcgYW5kIGhlYXZ5IGNvbXBhY3Rpb24gdG8gc3VjY2VlZCBhbmQNCj4gdGhlIHN1Y2Nlc3MgcmF0
ZSB0ZW5kcyB0byBiZSBwcmV0dHkgaGlnaCBmcm9tIG15IGV4cGVyaWVuY2UuICBXaHkgdGhhdA0K
PiBpcyBub3QgY2FzZSBpbiB5b3VyIGNhc2U/DQo+IA0KDQpZZXMsIEkgaGF2ZSB0aGUgc2FtZSBv
YnNlcnZhdGlvbjogd2l0aCBgR0ZQX1RSQU5TSFVHRSB8DQpfX0dGUF9SRVRSWV9NQVlGQUlMYCBJ
IGdldCB2ZXJ5IGdvb2Qgc3VjY2VzcyByYXRlICh+OTAlIG9mIGZyZWUgUkFNDQphbGxvY2F0ZWQg
YXMgaHVnZXBhZ2VzKS4gSG93ZXZlciwgd2hhdCBJJ20gdHJ5aW5nIHRvIHBvaW50IG91dCBpcyB0
aGF0IHRoaXMNCmhpZ2ggc3VjY2VzcyByYXRlIGNvbWVzIHdpdGggaGlnaCBhbGxvY2F0aW9uIGxh
dGVuY2llcyAoOTB0aCBwZXJjZW50aWxlDQpsYXRlbmN5IG9mIDIyMDZ1cykuIE9uIHRoZSBzYW1l
IHN5c3RlbSwgdGhlIHNhbWUgaGlnaC1vcmRlciBhbGxvY2F0aW9ucw0Kd2hpY2ggaGl0IHRoZSBm
YXN0IHBhdGggaGF2ZSBsYXRlbmN5IDw1dXMuDQoNCj4gPiA+ID4gSXQgaXMgYWxzbyBoYXJkIHRv
IGVmZmljaWVudGx5IGRldGVybWluZSBpZiB0aGUgY3VycmVudA0KPiA+ID4gPiBzeXN0ZW0gc3Rh
dGUgY2FuIGJlIGVhc2lseSBjb21wYWN0ZWQgZHVlIHRvIG1peGluZyBvZiB1bm1vdmFibGUNCj4g
PiA+ID4gbWVtb3J5LiBEdWUgdG8gdGhlc2UgcmVhc29ucywgYXV0b21hdGljIGJhY2tncm91bmQg
Y29tcGFjdGlvbiBieSB0aGUNCj4gPiA+ID4ga2VybmVsIGl0c2VsZiBpcyBoYXJkIHRvIGdldCBy
aWdodCBpbiBhIHdheSB3aGljaCBkb2VzIG5vdCBodXJ0DQo+ID4gPiA+IHVuc3VzcGVjdGluZw0K
PiA+ID4gYXBwbGljYXRpb25zIG9yIHdhc3RlIENQVSBjeWNsZXMuDQo+ID4gPiANCj4gPiA+IFdl
IGRvIHRyaWdnZXIgYmFja2dyb3VuZCBjb21wYWN0aW9uIG9uIGEgaGlnaCBvcmRlciBwcmVzc3Vy
ZSBmcm9tIHRoZQ0KPiA+ID4gcGFnZSBhbGxvY2F0b3IgYnkgd2FraW5nIHVwIGtjb21wYWN0ZC4g
V2h5IGlzIHRoYXQgbm90IHN1ZmZpY2llbnQ/DQo+ID4gPiANCj4gPiANCj4gPiBXaGVuZXZlciBr
Y29tcGFjdGQgaXMgd29rZW4gdXAsIGl0IGRvZXMganVzdCBlbm91Z2ggd29yayB0byBjcmVhdGUN
Cj4gPiBvbmUgZnJlZSBwYWdlIG9mIHRoZSBnaXZlbiBvcmRlciAoY29tcGFjdGlvbl9jb250cm9s
Lm9yZGVyKSBvciBoaWdoZXIuDQo+IA0KPiBUaGlzIGlzIGFuIGltcGxlbWVudGF0aW9uIGRldGFp
bCBJTUhPLiBJIGFtIHByZXR0eSBzdXJlIHdlIGNhbiBkbyBhDQo+IGJldHRlciBhdXRvIHR1bmlu
ZyB3aGVuIHRoZXJlIGlzIGFuIGluZGljYXRpb24gb2YgYSBjb25zdGFudCBmbG93IG9mDQo+IGhp
Z2ggb3JkZXIgcmVxdWVzdHMuIFRoaXMgaXMgbm8gZGlmZmVyZW50IGZyb20gdGhlIG1lbW9yeSBy
ZWNsYWltIGluDQo+IHByaW5jaXBsZS4gSnVzdCBiZWNhdXNlIHRoZSBrc3dhcGQgYXV0b3R1bmlu
ZyBub3QgZml0dGluZyB3aXRoIHlvdXINCj4gcGFydGljdWxhciB3b3JrbG9hZCB5b3Ugd291bGRu
J3Qgd2FudCB0byBleHBvcnQgZGlyZWN0IHJlY2xhaW0NCj4gZnVuY3Rpb25hbGl0eSBhbmQgY2Fs
bCBpdCBmcm9tIGEgcmFuZG9tIG1vZHVsZS4gVGhhdCBpcyBqdXN0IGRvb21lZCB0bw0KPiBmYWls
IGJlY2F1c2UgZGlmZmVyZW50IHN1YnN5c3RlbXMgaW4gY29udHJvbCBqdXN0IGxlYWRzIHRvIGRl
Y2lzaW9ucw0KPiBnb2luZyBhZ2FpbnN0IGVhY2ggb3RoZXIuDQo+IA0KDQpJIGRvbid0IHdhbnQg
dG8gZ28gdGhlIHJvdXRlIG9mIGFkZGluZyBhbnkgYXV0by10dW5pbmcvcGVyZGljdGlvbiBjb2Rl
IHRvDQpjb250cm9sIGNvbXBhY3Rpb24gaW4gdGhlIGtlcm5lbC4gSSdtIG1vcmUgaW5jbGluZWQg
dG93YXJkcyBleHRlbmRpbmcNCmV4aXN0aW5nIGludGVyZmFjZXMgdG8gYWxsb3cgY29tcGFjdGlv
biBiZWhhdmlvciB0byBiZSBjb250cm9sbGVkIGVpdGhlcg0KZnJvbSB1c2Vyc3BhY2Ugb3IgYSBr
ZXJuZWwgZHJpdmVyLiBMZXR0aW5nIGEgcmFuZG9tIG1vZHVsZSBjb250cm9sDQpjb21wYWN0aW9u
IG9yIGEgcm9vdCBwcm9jZXNzIHB1bXBpbmcgbmV3IHR1bmFibGVzIGZyb20gc3lzZnMgaXMgdGhl
IHNhbWUgaW4NCnByaW5jaXBsZS4NCg0KVGhpcyBwYXRjaCBpcyBpbiB0aGUgc3Bpcml0IG9mIHNp
bXBsZSBleHRlbnNpb24gdG8gZXhpc3RpbmcNCmNvbXBhY3Rpb25fem9uZV9vcmRlcigpIHdoaWNo
IGFsbG93cyBlaXRoZXIgYSBrZXJuZWwgZHJpdmVyIG9yIHVzZXJzcGFjZQ0KKHRocm91Z2ggc3lz
ZnMpIHRvIGNvbnRyb2wgY29tcGFjdGlvbi4NCg0KQWxzbywgd2Ugc2hvdWxkIGF2b2lkIGRyaXZp
bmcgaGFyZCBwYXJhbGxlbHMgYmV0d2VlbiByZWNsYWltIGFuZA0KY29tcGFjdGlvbjogdGhlIGZv
cm1lciBpcyBvZnRlbiBuZWNlc3NhcnkgZm9yIGZvcndhcmQgcHJvZ3Jlc3Mgd2hpbGUgdGhlDQps
YXR0ZXIgaXMgb2Z0ZW4gYW4gb3B0aW1pemF0aW9uLiBTaW5jZSBjb250aWd1b3VzIGFsbG9jYXRp
b25zIGFyZSBtb3N0bHkNCm9wdGltaXphdGlvbnMgaXQncyBnb29kIHRvIGV4cG9zZSBob29rcyBm
cm9tIHRoZSBrZXJuZWwgdGhhdCBsZXQgdXNlcg0KKHRocm91Z2ggYSBkcml2ZXIgb3IgdXNlcnNw
YWNlKSBjb250cm9sIGl0IHVzaW5nIGl0cyBvd24gaGV1cmlzdGljcy4NCg0KDQpJIHRob3VnaHQg
aGFyZCBhYm91dCB3aGF0cyBsYWNraW5nIGluIGN1cnJlbnQgdXNlcnNwYWNlIGludGVyZmFjZSAo
c3lzZnMpOg0KIC0gL3Byb2Mvc3lzL3ZtL2NvbXBhY3RfbWVtb3J5OiBmdWxsIHN5c3RlbSBjb21w
YWN0aW9uIGlzIG5vdCBhbiBvcHRpb24gYXMNCiAgIGEgdmlhYmxlIHByby1hY3RpdmUgY29tcGFj
dGlvbiBzdHJhdGVneS4NCiAtIHBvc3NpYmx5IGV4cG9zZSBbbG93LCBoaWdoXSB0aHJlc2hvbGQg
dmFsdWVzIGZvciBlYWNoIG5vZGUgYW5kIGxldA0KICAga2NvbXBhY3RkIGFjdCBvbiB0aGVtLiBU
aGlzIHdhcyBteSBhcHByb2FjaCBmb3IgbXkgb3JpZ2luYWwgcGF0Y2ggSQ0KICAgbGlua2VkIGVh
cmxpZXIuIFByb2JsZW0gaGVyZSBpcyB0aGF0IGl0IGludHJvZHVjZXMgdG9vIG1hbnkgdHVuYWJs
ZXMuDQoNCkNvbnNpZGVyaW5nIHRoZSBhYm92ZSwgSSBjYW1lIHVwIHdpdGggdGhpcyBjYWxsYmFj
ayBhcHByb2FjaCB3aGljaCBtYWtlIGl0DQp0cml2aWFsIHRvIGludHJvZHVjZSB1c2VyIHNwZWNp
ZmljIHBvbGljaWVzIGZvciBjb21wYWN0aW9uLiBJdCBwdXRzIHRoZQ0Kb251cyBvZiBzeXN0ZW0g
c3RhYmlsaXR5LCByZXNwb25zaXZlIGluIHRoZSBoYW5kcyBvZiB1c2VyIHdpdGhvdXQgYnVyZGVu
aW5nDQphZG1pbnMgd2l0aCBtb3JlIHR1bmFibGVzIG9yIGFkZGluZyBjcnlzdGFsIGJhbGxzIHRv
IGtlcm5lbC4NCg0KPiA+IFN1Y2ggYSBkZXNpZ24gY2F1c2VzIHZlcnkgaGlnaCBsYXRlbmN5IGZv
ciB3b3JrbG9hZHMgd2hlcmUgd2Ugd2FudA0KPiA+IHRvIGFsbG9jYXRlIGxvdHMgb2YgaHVnZXBh
Z2VzIGluIHNob3J0IHBlcmlvZCBvZiB0aW1lLiBXaXRoIHByby1hY3RpdmUNCj4gPiBjb21wYWN0
aW9uIHdlIGNhbiBoaWRlIG11Y2ggb2YgdGhpcyBsYXRlbmN5LiBGb3Igc29tZSBtb3JlIGJhY2tn
cm91bmQNCj4gPiBkaXNjdXNzaW9uIGFuZCBkYXRhLCBwbGVhc2Ugc2VlIHRoaXMgdGhyZWFkOg0K
PiA+IA0KPiA+IGh0dHBzOi8vcGF0Y2h3b3JrLmtlcm5lbC5vcmcvcGF0Y2gvMTEwOTgyODkvDQo+
IA0KPiBJIGFtIGF3YXJlIG9mIHRoYXQgdGhyZWFkLiBBbmQgdGhlcmUgYXJlIHR3byB0aGluZ3Mu
IFlvdSBjbGFpbSB0aGUNCj4gYWxsb2NhdGlvbiBzdWNjZXNzIHJhdGUgaXMgdW5uZWNlc3Nhcmls
eSBsb3dlciBhbmQgdGhhdCB0aGUgZGlyZWN0DQo+IGxhdGVuY3kgaXMgaGlnaC4gWW91IHNpbXBs
eSBjYW5ub3QgYXNzdW1lIGJvdGggbG93IGxhdGVuY3kgYW5kIGhpZ2gNCj4gc3VjY2VzcyByYXRl
LiBDb21wYWN0aW9uIGlzIG5vdCBmcmVlLiBTb21lYm9keSBoYXMgdG8gZG8gdGhlIHdvcmsuDQo+
IEhpZGluZyBpdCBpbnRvIHRoZSBiYWNrZ3JvdW5kIG1lYW5zIHRoYXQgeW91IGFyZSBlYXRpbmcg
YSBsb3Qgb2YgY3ljbGVzDQo+IGZyb20gZXZlcnlib2R5IGVsc2UgKHRoaW5rIG9mIGEgd29ya2xv
YWQgcnVubmluZyBpbiBhIHJlc3RyaWN0ZWQgY3B1DQo+IGNvbnRyb2xsZXIganVzdCBkb2luZyBh
IGxvdCBvZiB3b3JrIGluIGFuIHVuYWNjb3VudGVkIGNvbnRleHQpLg0KPiANCj4gVGhhdCBiZWlu
ZyBzYWlkIHlvdSByZWFsbHkgaGF2ZSB0byBiZSBwcmVwYXJlZCB0byBwYXkgYSBwcmljZSBmb3IN
Cj4gcHJlY2lvdXMgcmVzb3VyY2UgbGlrZSBoaWdoIG9yZGVyIHBhZ2VzLg0KPiANCj4gT24gdGhl
IG90aGVyIGhhbmQgSSBkbyB1bmRlcnN0YW5kIHRoYXQgaGlnaCBsYXRlbmN5IGlzIG5vdCByZWFs
bHkNCj4gZGVzaXJlZCBmb3IgYSBtb3JlIG9wdGltaXN0aWMgYWxsb2NhdGlvbiByZXF1ZXN0cyB3
aXRoIGEgcmVhc29uYWJsZQ0KPiBmYWxsYmFjayBzdHJhdGVneS4gVGhvc2Ugd291bGQgYmVuZWZp
dCBmcm9tIGtjb21wYWN0ZCBub3QgZ2l2aW5nIHVwIHRvbw0KPiBlYXJseS4NCg0KRG9pbmcgcHJv
LWFjdGl2ZSBjb21wYWN0aW9uIGluIGJhY2tncm91bmQgaGFzIG1lcml0cyBpbiByZWR1Y2luZyBy
ZWR1Y2luZw0KaGlnaC1vcmRlciBhbGxvYyBsYXRlbmN5LiBJdHMgdHJ1ZSB0aGF0IGl0IHdvdWxk
IGVuZCB1cCBidXJuaW5nIGN5Y2xlcyB3aXRoDQpsaXR0bGUgYmVuZWZpdCBpbiBzb21lIGNhc2Vz
LiBJdHMgdXB0byB0aGUgdXNlciBvZiB0aGlzIG5ldyBpbnRlcmZhY2UgdG8NCmJhY2sgb2ZmIGlm
IGl0IGRldGVjdHMgc3VjaCBhIGNhc2UuDQoNCj4gIA0KPiA+ID4gPiBFdmVuIHdpdGggdGhlc2Ug
Y2F2ZWF0cywgcHJvLWFjdGl2ZSBjb21wYWN0aW9uIGNhbiBzdGlsbCBiZSB2ZXJ5DQo+ID4gPiA+
IHVzZWZ1bCBpbiBjZXJ0YWluIHNjZW5hcmlvcyB0byByZWR1Y2UgaHVnZXBhZ2UgYWxsb2NhdGlv
biBsYXRlbmNpZXMuDQo+ID4gPiA+IFRoaXMgY2FsbGJhY2sgaW50ZXJmYWNlIGFsbG93cyBkcml2
ZXJzIHRvIGRyaXZlIGNvbXBhY3Rpb24gYmFzZWQgb24NCj4gPiA+ID4gdGhlaXIgb3duIHBvbGlj
aWVzIGxpa2UgdGhlIGN1cnJlbnQgbGV2ZWwgb2YgZXh0ZXJuYWwgZnJhZ21lbnRhdGlvbg0KPiA+
ID4gPiBmb3IgYSBwYXJ0aWN1bGFyIG9yZGVyLCBzeXN0ZW0gbG9hZCBldGMuDQo+ID4gPiANCj4g
PiA+IFNvIHdlIGRvIG5vdCB0cnVzdCB0aGUgY29yZSBNTSB0byBtYWtlIGEgcmVhc29uYWJsZSBk
ZWNpc2lvbiB3aGlsZSB3ZQ0KPiA+ID4gZ2l2ZQ0KPiA+ID4gYSBmcmVlIHRpY2tldCB0byBtb2R1
bGVzLiBIb3cgZG9lcyB0aGlzIG1ha2UgYW55IHNlbnNlIGF0IGFsbD8gSG93IGlzIGENCj4gPiA+
IHJhbmRvbSBtb2R1bGUgZ29pbmcgdG8gbWFrZSBhIG1vcmUgaW5mb3JtZWQgZGVjaXNpb24gd2hl
biBpdCBoYXMgbGVzcw0KPiA+ID4gdmlzaWJpbGl0eSBvbiB0aGUgb3ZlcmFsIE1NIHNpdHVhdGlv
bi4NCj4gPiA+IA0KPiA+IA0KPiA+IEVtYmVkZGluZyBhbnkgc3BlY2lmaWMgcG9saWN5IChsaWtl
OiBrZWVwIGV4dGVybmFsIGZyYWdtZW50YXRpb24gZm9yDQo+ID4gb3JkZXItOQ0KPiA+IGJldHdl
ZW4gMzAtNDAlKSB3aXRoaW4gTU0gY29yZSBsb29rcyBsaWtlIGEgYmFkIGlkZWEuDQo+IA0KPiBB
Z3JlZWQNCj4gDQo+ID4gQXMgYSBkcml2ZXIsIHdlDQo+ID4gY2FuIGVhc2lseSBtZWFzdXJlIHBh
cmFtZXRlcnMgbGlrZSBzeXN0ZW0gbG9hZCwgY3VycmVudCBmcmFnbWVudGF0aW9uDQo+ID4gbGV2
ZWwNCj4gPiBmb3IgYW55IG9yZGVyIGluIGFueSB6b25lIGV0Yy4gdG8gbWFrZSBhbiBpbmZvcm1l
ZCBkZWNpc2lvbi4NCj4gPiBTZWUgdGhlIHRocmVhZCBJIHJlZmVyZWVkIGFib3ZlIGZvciBtb3Jl
IGJhY2tncm91bmQgZGlzY3Vzc2lvbi4NCj4gDQo+IERvIHRoYXQgZnJvbSB0aGUgdXNlcnNwYWNl
IHRoZW4uIElmIHRoZXJlIGlzIGFuIGluc3VmZmljaWVudCBpbnRlcmZhY2UNCj4gdG8gZG8gdGhh
dCB0aGVuIGxldCdzIHRhbGsgYWJvdXQgd2hhdCBpcyBtaXNzaW5nLg0KPiANCg0KQ3VycmVudGx5
IHdlIG9ubHkgaGF2ZSBhIHByb2MgaW50ZXJmYWNlIHRvIGRvIGZ1bGwgc3lzdGVtIGNvbXBhY3Rp
b24uDQpIZXJlJ3Mgd2hhdCBtaXNzaW5nIGZyb20gdGhpcyBpbnRlcmZhY2U6IGFiaWxpdHkgdG8g
c2V0IHBlci1ub2RlLCBwZXItem9uZSwNCnBlci1vcmRlciwgW2xvdywgaGlnaF0gZXh0ZnJhZyB0
aHJlc2hvbGRzLiBUaGlzIGlzIHdoYXQgSSBleHBvc2VkIGluIG15DQplYXJsaWVyIHBhdGNoIHRp
dGxlZCAncHJvYWN0aXZlIGNvbXBhY3Rpb24nLiBEaXNjdXNzaW9uIHRoZXJlIG1hZGUgbWUgcmVh
bGl6ZQ0KdGhlc2UgYXJlIHRvbyBtYW55IHR1bmFibGVzIGFuZCBhbnkgYWRtaW4gd291bGQgYWx3
YXlzIGdldCB0aGVtIHdyb25nLiBFdmVuDQppZiBpbnRlbmRlZCB1c2VyIG9mIHRoZXNlIHN5c2Zz
IG5vZGUgaXMgc29tZSBtb25pdG9yaW5nIGRhZW1vbiwgaXRzDQp0ZW1wdGluZyB0byBtZXNzIHdp
dGggdGhlbS4NCg0KV2l0aCBhIGNhbGxiYWNrIGV4dGVuc2lvbiB0byBjb21wYWN0X3pvbmVfb3Jk
ZXIoKSBpbXBsZW1lbnRpbmcgYW55IG9mIHRoZQ0KcGVyLW5vZGUsIHBlci16b25lLCBwZXItb3Jk
ZXIgbGltaXRzIGlzIHN0cmFpZ2h0Zm9yd2FyZCBhbmQgaWYgbmVlZGVkIHRoZQ0KZHJpdmVyIGNh
biBleHBvc2UgZGVidWdmcy9zeXNmcyBub2RlcyBpZiBuZWVkZWQgYXQgYWxsLiAobnZjb21wYWN0
LmMNCmRyaXZlclsxXSBleHBvc2VzIHRoZXNlIHR1bmFibGVzIGFzIGRlYnVnZnMgbm9kZXMsIGZv
ciBleGFtcGxlKS4NCg0KWzFdIGh0dHBzOi8vZ2l0bGFiLmNvbS9uaWd1cHRhL2xpbnV4L3NuaXBw
ZXRzLzE4OTQxNjENCg0KDQo+ID4gPiBJZiB5b3UgbmVlZCB0byBjb250cm9sIGNvbXBhY3Rpb24g
ZnJvbSB0aGUgdXNlcnNwYWNlIHlvdSBoYXZlIGFuDQo+ID4gPiBpbnRlcmZhY2UNCj4gPiA+IGZv
ciB0aGF0LiAgSXQgaXMgYWxzbyBjb21wbGV0ZWx5IHVuZXhwbGFpbmVkIHdoeSB5b3UgbmVlZCBh
IGNvbXBsZXRpb24NCj4gPiA+IGNhbGxiYWNrLg0KPiA+ID4gDQo+ID4gDQo+ID4gL3Byb2Mvc3lz
L3ZtL2NvbXBhY3RfbWVtb3J5IGRvZXMgd2hvbGUgc3lzdGVtIGNvbXBhY3Rpb24gd2hpY2ggaXMN
Cj4gPiBvZnRlbiB0b28gbXVjaCBhcyBhIHByby1hY3RpdmUgY29tcGFjdGlvbiBzdHJhdGVneS4g
VG8gZ2V0IG1vcmUgY29udHJvbA0KPiA+IG92ZXIgaG93IHRvIGNvbXBhY3Rpb24gd29yayB0byBk
bywgSSBoYXZlIGFkZGVkIGEgY29tcGFjdGlvbiBjYWxsYmFjaw0KPiA+IHdoaWNoIGNvbnRyb2xz
IGhvdyBtdWNoIHdvcmsgaXMgZG9uZSBpbiBvbmUgY29tcGFjdGlvbiBjeWNsZS4NCj4gDQo+IFdo
eSBpcyBhIG1vcmUgZmluZSBncmFpbmVkIGNvbnRyb2wgcmVhbGx5IG5lZWRlZD8gU3VyZSBjb21w
YWN0aW5nDQo+IGV2ZXJ5dGhpbmcgaXMgaGVhdnkgd2VpZ2h0IGJ1dCBob3cgb2Z0ZW4gZG8geW91
IGhhdmUgdG8gZG8gdGhhdC4gWW91cg0KPiBjaGFuZ2Vsb2cgc3RhcnRzIHdpdGggYSB1c2VjYXNl
IHdoZW4gdGhlcmUgaXMgYSBoaWdoIGRlbWFuZCBmb3IgbGFyZ2UNCj4gcGFnZXMgYXQgdGhlIHN0
YXJ0dXAuIFdoYXQgcHJldmVudHMgeW91IGRvIGNvbXBhY3Rpb24gYXQgdGhhdCB0aW1lLiBJZg0K
PiB0aGUgd29ya2xvYWQgaXMgbG9uZ3Rlcm0gdGhlbiB0aGUgaW5pdGlhbCBwcmljZSBzaG91bGQg
anVzdCBwYXkgYmFjaywNCj4gbm8/DQo+IA0KDQpDb21wYWN0aW5nIGFsbCBOVU1BIG5vZGVzIGlz
IG5vdCBwcmFjdGljYWwgb24gbGFyZ2Ugc3lzdGVtcyBpbiByZXNwb25zZSB0bywNCnNheSwgbGF1
bmNoaW5nIGEgREIgcHJvY2VzcyBvbiBhIGNlcnRhaW4gbm9kZS4gQWxzbywgdGhlIGZyZXF1ZW5j
eSBvZg0KaHVnZXBhZ2UgYWxsb2NhdGlvbiBidXJ0cyBtYXkgYmUgY29tcGxldGVseSB1bnByZWRp
Y3RhYmxlLiBUaGF0J3Mgd2h5DQpiYWNrZ3JvdW5kIGNvbXBhY3Rpb24gY2FuIGtlZXAgZXh0ZnJh
ZyBpbiBjaGVjaywgc2F5IHdoaWxlIHN5c3RlbSBpcw0KbGlnaHRseSBsb2FkZWQgKGFkaG9jIHBv
bGljeSksIGtlZXBpbmcgaGlnaC1vcmRlciBhbGxvY2F0aW9uIGxhdGVuY2llcyBsb3cNCndoZW5l
dmVyIHRoZSBidXJzdCBzaG93cyB1cC4NCg0KLSBOaXRpbg0KDQo=

