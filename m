Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEA94C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:23:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2AE422CE3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:23:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="AOd/sPDn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2AE422CE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AD336B030B; Wed, 21 Aug 2019 12:23:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25CD46B030C; Wed, 21 Aug 2019 12:23:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14BE56B030D; Wed, 21 Aug 2019 12:23:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id E27C56B030B
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:23:25 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8C1A4180AD803
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:23:25 +0000 (UTC)
X-FDA: 75846955170.25.cause48_57fc9c056a10d
X-HE-Tag: cause48_57fc9c056a10d
X-Filterd-Recvd-Size: 7585
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-eopbgr790085.outbound.protection.outlook.com [40.107.79.85])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:23:24 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=iPFzk8auU2TN2S9qug5sRsvDk7nt2AixohJVifMCMbNRWau9wISuEd0UdDwSd+lOoJkFSWnTTBMpy3fCl/I/0ZCdqjGzOAJCnZiCGmOIEH08ZWt7evDJhGC8iSdx9zsElDEXb/AFhXG+RBm6vliuW9TqEpaSuYCzv1VGType371k0EYxnyXsnJCzAHaiEebJHxtJy9yVLJ6bw1zRa5SHnC/ttfnL39JVfMT3cZeO5KQTwFvapOhASTyzsu49WtrIdzHXcRXr8Mxf31l8LOQDlLlRmi1G2za8M8M4DvBlNxz06hcGv8tpoz8H+7bGb+rHP97VH/JpFeVYyKnQ3+EMtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=I9tlPJtLZC99Tns9udnrluz2F9EERVnPcn7qiebsrQE=;
 b=YMKkq210jeK1xJcwwakmVXdKoBRc8tmc01FNwEDNht0BMOUbCnSQd2wSjqOUfB5A9u6OushanuSxP+GqEhKE44UWTt6czgTJmmbpimkPnbEjYzC+wYkpOqEmSk7CHDlGlC+J5JDHkA0T/+I38Dh8Qk4SLH/wSIJEK/HbPosJncVWYuJ6N9Kf6wwHjuSkS+3l7pDzPQ3D8pskLuZsSL9H41wtcC1Dpt7MqYUTDYWiQFWhTt68MfYEqW4yA4Hy7Ekh/a78wmUsPYhvuVEozdlacusL6NYOCUBSeA3VBSZiGffWk4vLRLqHYmVOLRSdTivBTuF25xpVagb/q9gOE1pzWQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=vmware.com; dmarc=pass action=none header.from=vmware.com;
 dkim=pass header.d=vmware.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=I9tlPJtLZC99Tns9udnrluz2F9EERVnPcn7qiebsrQE=;
 b=AOd/sPDnClXQvtmU9My1HYwiLSbDRNX+0JCO152JpThQTQktdGVBx6BnU8w44f/nSTM0j/3y454V3u7J6hUEvCrrx5jGPDE7iZMyxWr71xAMN8PA+ER9VB52zuxPVoM5w1w8UPNDHRQ0M+xu8VWOi8r9hvEWlFOwmqyqnsFS1KE=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5237.namprd05.prod.outlook.com (20.177.231.87) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2199.11; Wed, 21 Aug 2019 16:23:22 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::1541:ed53:784a:6376]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::1541:ed53:784a:6376%5]) with mapi id 15.20.2199.011; Wed, 21 Aug 2019
 16:23:22 +0000
From: Nadav Amit <namit@vmware.com>
To: David Hildenbrand <david@redhat.com>
CC: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/balloon_compaction: suppress allocation warnings
Thread-Topic: [PATCH] mm/balloon_compaction: suppress allocation warnings
Thread-Index: AQHVV3WT44k5kIt6JEiYnWTDWJ3OpKcFxbMAgAAE4IA=
Date: Wed, 21 Aug 2019 16:23:22 +0000
Message-ID: <5BBC6CB3-2DCD-4A95-90C9-7C23482F9B32@vmware.com>
References: <20190820091646.29642-1-namit@vmware.com>
 <ba01ec8c-19c3-847c-a315-2f70f4b1fe31@redhat.com>
In-Reply-To: <ba01ec8c-19c3-847c-a315-2f70f4b1fe31@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7ab1e096-5beb-4c96-e3c5-08d72653e2e2
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR05MB5237;
x-ms-traffictypediagnostic: BYAPR05MB5237:
x-microsoft-antispam-prvs:
 <BYAPR05MB523742FCCE03F64596033B5AD0AA0@BYAPR05MB5237.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0136C1DDA4
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(136003)(346002)(396003)(39860400002)(376002)(199004)(189003)(3846002)(6116002)(33656002)(14454004)(478600001)(316002)(6246003)(66066001)(6916009)(25786009)(53936002)(305945005)(7736002)(36756003)(66446008)(2906002)(4326008)(64756008)(66556008)(66476007)(5660300002)(66946007)(6512007)(8936002)(6486002)(54906003)(76116006)(476003)(2616005)(446003)(86362001)(99286004)(14444005)(486006)(71190400001)(71200400001)(8676002)(81156014)(81166006)(229853002)(6506007)(102836004)(53546011)(186003)(76176011)(26005)(11346002)(256004)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5237;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 R748NA9GD0TV+rQ+LpypWiIwKXqTHGcXFoo3YnvoudfZnB5NgeSrkecA2xFUdZ1poHUIi7a1uBXKMh47DUbBzb0MSMRo8bPK9lxxfhwiDN8NoQLlmEVK2jSsb6ih5zaBPdHC8xHlkf7gNeyIIekI4knI0oKMl0TO+eX4TDhIRcOxkqKmWYDrNyB4zy4j1xwlvPau7/DMluciYkUMWm4zKr1ujTyyYSmw7G1t8M+1lmmhhz06j6KRDV6sS5poN81tVZNFRolFzzocCGO6YiF1wOrcpCc6uQx9bfziBYxRP6J6cXhRs6k8JgkzITozdfyIaRLx9kZ28IHj2zLY6hNDlt585t8y8NOpSrQgBOTxBMvV9aQsg8dmHT7IE8I8aQqJ9rvUEFH/kHo63lrqYlJYppFpWh5jP6rzqGFdjW0B94w=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <A6726210375C704692078D756D10D1B3@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7ab1e096-5beb-4c96-e3c5-08d72653e2e2
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Aug 2019 16:23:22.5316
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: QRdCV6qpuhm0WxQz7a7hRGGXBR/2b9w/SlOdBhDKm0n6kX9LIuZ1712eOHEI1KF5jdLA7S9WUwymYjR7zy3RSg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5237
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001118, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBBdWcgMjEsIDIwMTksIGF0IDk6MDUgQU0sIERhdmlkIEhpbGRlbmJyYW5kIDxkYXZpZEBy
ZWRoYXQuY29tPiB3cm90ZToNCj4gDQo+IE9uIDIwLjA4LjE5IDExOjE2LCBOYWRhdiBBbWl0IHdy
b3RlOg0KPj4gVGhlcmUgaXMgbm8gcmVhc29uIHRvIHByaW50IHdhcm5pbmdzIHdoZW4gYmFsbG9v
biBwYWdlIGFsbG9jYXRpb24gZmFpbHMsDQo+PiBhcyB0aGV5IGFyZSBleHBlY3RlZCBhbmQgY2Fu
IGJlIGhhbmRsZWQgZ3JhY2VmdWxseS4gIFNpbmNlIFZNd2FyZQ0KPj4gYmFsbG9vbiBub3cgdXNl
cyBiYWxsb29uLWNvbXBhY3Rpb24gaW5mcmFzdHJ1Y3R1cmUsIGFuZCBzdXBwcmVzc2VkIHRoZXNl
DQo+PiB3YXJuaW5ncyBiZWZvcmUsIGl0IGlzIGFsc28gYmVuZWZpY2lhbCB0byBzdXBwcmVzcyB0
aGVzZSB3YXJuaW5ncyB0bw0KPj4ga2VlcCB0aGUgc2FtZSBiZWhhdmlvciB0aGF0IHRoZSBiYWxs
b29uIGhhZCBiZWZvcmUuDQo+IA0KPiBJIGFtIG5vdCBzdXJlIGlmIHRoYXQncyBhIGdvb2QgaWRl
YS4gVGhlIGFsbG9jYXRpb24gd2FybmluZ3MgYXJlIHVzdWFsbHkNCj4gdGhlIG9ubHkgdHJhY2Ug
b2YgInRoZSB1c2VyL2FkbWluIGRpZCBzb21ldGhpbmcgYmFkIGJlY2F1c2UgaGUvc2hlIHRyaWVk
DQo+IHRvIGluZmxhdGUgdGhlIGJhbGxvb24gdG8gYW4gdW5zYWZlIHZhbHVlIi4gQmVsaWV2ZSBt
ZSwgSSBwcm9jZXNzZWQgYQ0KPiBjb3VwbGUgb2Ygc3VjaCBidWdyZXBvcnRzIHJlbGF0ZWQgdG8g
dmlydGlvLWJhbGxvb24gYW5kIHRoZSB3YXJuaW5nIHdlcmUNCj4gdmVyeSBoZWxwZnVsIGZvciB0
aGF0Lg0KDQpPaywgc28gYSBtZXNzYWdlIGlzIG5lZWRlZCwgYnV0IGRvZXMgaXQgaGF2ZSB0byBi
ZSBhIGdlbmVyaWMgZnJpZ2h0ZW5pbmcNCndhcm5pbmc/DQoNCkhvdyBhYm91dCB1c2luZyBfX0dG
UF9OT1dBUk4sIGFuZCBpZiBhbGxvY2F0aW9uIGRvIHNvbWV0aGluZyBsaWtlOg0KDQogIHByX3dh
cm4o4oCcQmFsbG9vbiBtZW1vcnkgYWxsb2NhdGlvbiBmYWlsZWTigJ0pOw0KDQpPciBldmVuIHNv
bWV0aGluZyBtb3JlIGluZm9ybWF0aXZlPyBUaGlzIHdvdWxkIHN1cmVseSBiZSBsZXNzIGludGlt
aWRhdGluZw0KZm9yIGNvbW1vbiB1c2Vycy4NCg0K

